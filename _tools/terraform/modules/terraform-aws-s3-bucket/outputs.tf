output "bucket_id" {
  value = aws_s3_bucket.encrypted_bucket.id
}

output "bucket_arn" {
  value = aws_s3_bucket.encrypted_bucket.arn
}

output "bucket_domain_name" {
  value = aws_s3_bucket.encrypted_bucket.bucket_domain_name
}

output "bucket_regional_domain_name" {
  value = aws_s3_bucket.encrypted_bucket.bucket_regional_domain_name
}