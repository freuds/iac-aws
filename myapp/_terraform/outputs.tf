
output "lambda_bucket_name" {
  description = "Name of the S3 bucket used to store function code."
  value       = module.lambda.lambda_bucket_name
}
output "function_name" {
  description = "Name of the Lambda function."
  value       = module.lambda.function_name
}

output "lambda_invoke_arn" {
  description = "ARN of lambda"
  value       = module.lambda.lambda_invoke_arn
}

output "apigateway_base_uri" {
  description = "Base URL for API Gateway stage."
  value = module.apigateway.base_url
}