module "lambda" {
  source             = "git@github.com:xxxxxxxxxxxxxx/terraform-aws-lambda.git"
  env                = var.env
  region             = var.region
  bucket_name        = var.lambda_name
  lambda_name        = var.lambda_name
  lambda_handler     = var.lambda_handler
  lambda_runtime     = var.lambda_runtime
  subnet_ids         = data.terraform_remote_state.vpc.outputs.private_subnets
  security_group_ids = data.terraform_remote_state.vpc.outputs.sg_vpc_endpoint_lambda_id
  xray_enable        = var.xray_enable
}

data "aws_lambda_function" "current" {
  function_name = var.lambda_name

  depends_on = [
    module.lambda.function_name
  ]
}

module "apigateway" {
  source              = "git@github.com:xxxxxxxxxxxxxx/terraform-aws-apitgateway.git"
  env                 = var.env
  service             = var.service
  region              = var.region
  integration_uri     = data.aws_lambda_function.current.invoke_arn
  function_name       = data.aws_lambda_function.current.function_name
  subnet_ids          = data.terraform_remote_state.vpc.outputs.private_subnets
  security_group_ids  = data.terraform_remote_state.vpc.outputs.sg_vpc_endpoint_lambda_id
  certificat_arn      = data.terraform_remote_state.vpc.outputs.ssl_cert_arn
  public_domain       = data.terraform_remote_state.vpc.outputs.public_domain
  public_host_zone_id = data.terraform_remote_state.vpc.outputs.public_host_zone_id
}