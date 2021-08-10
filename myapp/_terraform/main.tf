module "lambda" {
  source         = "git@github.com:xxxxxxxxxxxxxx/terraform-aws-lambda.git"
  env            = var.env
  region         = var.region
  bucket_name    = var.lambda_name
  lambda_name    = var.lambda_name
  lambda_handler = var.lambda_handler
  lambda_runtime = var.lambda_runtime
}

module "apigateway" {
  source         = "git@github.com:xxxxxxxxxxxxxx/terraform-aws-apitgateway.git"
  env            = var.env
  region         = var.region
}