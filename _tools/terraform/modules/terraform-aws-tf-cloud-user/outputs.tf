output "tf_cloud_access_key" {
  value = aws_iam_access_key.tf-cloud.id
}

output "tf_cloud_secret" {
  value     = aws_iam_access_key.tf-cloud.secret
  sensitive = true
}