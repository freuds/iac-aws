output "cloudfront_distribution_domain_name" {
  description = "The domain name of the cloudfront distribution"
  value       = module.cdn-assets.cloudfront_distribution_domain_name
}

output "cloudfront_distribution_arn" {
  description = "The ARN of the cloudfront distribution"
  value       = module.cdn-assets.cloudfront_distribution_arn
}

output "tf_s3_access_key" {
  value = aws_iam_access_key.tf-s3.*.id
}

output "tf_s3_secret" {
  value     = aws_iam_access_key.tf-s3.*.secret
  sensitive = true
}