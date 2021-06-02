output "cloudfront_distribution_domain_name" {
  description = "The domain name of the cloudfront distribution"
  value       = aws_cloudfront_distribution.api_distribution.domain_name
}

output "cloudfront_distribution_arn" {
  description = "The ARN of the cloudfront distribution"
  value       = aws_cloudfront_distribution.api_distribution.arn
}