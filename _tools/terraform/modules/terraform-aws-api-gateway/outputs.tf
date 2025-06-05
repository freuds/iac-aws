output "base_url" {
  description = "Base URL for API Gateway stage."
  value       = aws_apigatewayv2_stage.stage.invoke_url
}

output "domain_name_arn" {
  description = "The ARN of the domain name"
  value       = aws_apigatewayv2_domain_name.domain.arn
}