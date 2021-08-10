# Output value definitions

output "lambda_bucket_name" {
  description = "Name of the S3 bucket used to store function code."
  value       = aws_s3_bucket.lambda_bucket.id
}
output "function_name" {
  description = "Name of the Lambda function."
  value       = aws_lambda_function.this_lambda_name.function_name
}
output "lambda_invoke_arn" {
  description = "Invoke ARN of the Lambda function."
  value       = aws_lambda_function.this_lambda_name.invoke_arn
}

