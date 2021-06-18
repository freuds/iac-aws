output "cloudfront_distribution_domain_name" {
  description = "The domain name of the cloudfront distribution"
  value       = aws_cloudfront_distribution.assets_distribution.domain_name
}

output "cloudfront_distribution_arn" {
  description = "The ARN of the cloudfront distribution"
  value       = aws_cloudfront_distribution.assets_distribution.arn
}

output "origin_access_identity_arn" {
  description = "ARN from the origin access identity"
  value       = aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn
}