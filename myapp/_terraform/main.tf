module "lambda" {
  source         = "git@github.com:xxxxxxxxxxxxxx/terraform-aws-lambda.git"
  env            = var.env
  region         = var.region
  bucket_name    = var.lambda_name
  lambda_name    = var.lambda_name
  lambda_handler = var.lambda_handler
  lambda_runtime = var.lambda_runtime
}

data "aws_lambda_function" "helloword" {
  function_name = format("%s-%s", var.env, var.lambda_name)
}

module "apigateway" {
  source          = "git@github.com:xxxxxxxxxxxxxx/terraform-aws-apitgateway.git"
  env             = var.env
  service         = var.service
  region          = var.region
  integration_uri = data.aws_lambda_function.helloword.invoke_arn
  function_name   = data.aws_lambda_function.helloword.function_name
}