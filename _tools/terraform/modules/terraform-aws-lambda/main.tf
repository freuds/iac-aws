resource "aws_s3_bucket" "lambda_bucket" {
  bucket        = format("lambda-bucket-%s", var.lambda_name)
  acl           = "private"
  force_destroy = var.force_destroy
}

// content lambda into s3
data "archive_file" "this_lambda" {
  type = "zip"

  source_dir  = "../../../lambdas/${var.lambda_name}"
  output_path = "../../../lambdas/${var.lambda_name}.zip"
}

resource "aws_s3_bucket_object" "this_lambda" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = format("%s.zip", var.lambda_name)
  source = data.archive_file.this_lambda.output_path

  etag = filemd5(data.archive_file.this_lambda.output_path)
}

// build lambda function
resource "aws_lambda_function" "this_lambda_name" {
  function_name = var.lambda_name

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_bucket_object.this_lambda.key

  runtime = var.lambda_runtime
  handler = format("%s.handler", var.lambda_handler)

  source_code_hash = data.archive_file.this_lambda.output_base64sha256

  role = aws_iam_role.lambda_exec.arn
}

resource "aws_cloudwatch_log_group" "this_lambda_name" {
  name = "/aws/lambda/${aws_lambda_function.this_lambda_name.function_name}"
  retention_in_days = 30
}

resource "aws_iam_role" "lambda_exec" {
  name = format("role-lambda-%s", var.lambda_name)

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}