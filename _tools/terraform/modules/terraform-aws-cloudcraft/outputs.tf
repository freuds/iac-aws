
output "iam_role_arn" {
  description = "ARN of IAM role created"
  value       = aws_iam_role.tf_cloudcraft.arn
}
