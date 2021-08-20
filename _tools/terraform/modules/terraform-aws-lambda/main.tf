resource "aws_s3_bucket" "lambda_bucket" {
  bucket        = format("lambda-bucket-%s-%s", var.env, var.lambda_name)
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
  function_name = format("%s-%s", var.env, var.lambda_name)

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_bucket_object.this_lambda.key

  runtime = var.lambda_runtime
  handler = format("%s.handler", var.lambda_handler)

  source_code_hash = data.archive_file.this_lambda.output_base64sha256

  role = aws_iam_role.lambda_exec.arn

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }

  tracing_config {
    mode = "Active"
  }

  depends_on = [
    aws_iam_role.lambda_exec
  ]
}

resource "aws_cloudwatch_log_group" "this_lambda_name" {
  name              = "/aws/lambda/${aws_lambda_function.this_lambda_name.function_name}"
  retention_in_days = 30
}

//---------------------------//
// IAM role for lambda
//---------------------------//
resource "aws_iam_role" "lambda_exec" {
  name               = format("role-lambda-%s-%s", var.env, var.lambda_name)
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

data "aws_iam_policy_document" "lambda_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "lambda_exec_basic" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_exec_vpc" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_exec_xray" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
}

// resource "aws_iam_role_policy_attachment" "lambda_exec_insight" {
//   role       = aws_iam_role.lambda_exec.name
//   policy_arn = "arn:aws:iam::aws:policy/CloudWatchLambdaInsightsExecutionRolePolicy"
// }

// lambda permissions with SNS
// resource "aws_lambda_permission" "with_sns" {
//   statement_id  = "AllowExecutionFromSNS"
//   action        = "lambda:InvokeFunction"
//   function_name = aws_lambda_function.func.function_name
//   principal     = "sns.amazonaws.com"
//   source_arn    = aws_sns_topic.default.arn
// }

// resource "aws_sns_topic" "default" {
//   name = "call-lambda-maybe"
// }

// resource "aws_sns_topic_subscription" "lambda" {
//   topic_arn = aws_sns_topic.default.arn
//   protocol  = "lambda"
//   endpoint  = aws_lambda_function.func.arn
// }

// resource "aws_lambda_layer_version" "example" {
//   # ... other configuration ...
// }

// resource "aws_lambda_function" "example" {
//   # ... other configuration ...
//   layers = [aws_lambda_layer_version.example.arn]
// }