module "lambda" {
  source = "../../../_tools/terraform/modules/terraform-aws-lambda"
}
module "apigateway" {
  source = "../../../_tools/terraform/modules/terraform-aws-api-gateway"
}
