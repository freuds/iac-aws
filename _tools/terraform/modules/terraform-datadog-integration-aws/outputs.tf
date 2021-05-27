output "datadog_external_id" {
  value = datadog_integration_aws.datadog_aws_integration.external_id
}

output "datadog_role_name" {
  value = aws_iam_role.datadog_aws_integration.name
}

output "datadog_policy_arn" {
  value = aws_iam_policy.datadog_aws_integration.arn
}