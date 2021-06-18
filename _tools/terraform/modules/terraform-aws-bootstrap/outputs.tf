output "account_arns" {
  value = zipmap(keys(var.accounts), aws_organizations_account.account.*.arn)
}

output "account_ids" {
  value = zipmap(keys(var.accounts), aws_organizations_account.account.*.id)
}

output "account_emails" {
  value = zipmap(keys(var.accounts), values(var.accounts))
}

output "org_arn" {
  value = aws_organizations_organization.org.arn
}

output "org_id" {
  value = aws_organizations_organization.org.id
}

output "master_account_arn" {
  value = aws_organizations_organization.org.master_account_arn
}

output "master_account_email" {
  value = aws_organizations_organization.org.master_account_email
}

output "master_account_id" {
  value = aws_organizations_organization.org.master_account_id
}

output "iam_admin_role_name" {
  value = var.iam_admin_role_name
}

output "iam_user_tf_cloud" {
  value = aws_iam_user.tf-cloud
}

output "iam_user_tf_cloud_access_key" {
  value = aws_iam_access_key.tf-cloud.id
}

output "iam_user_tf_cloud_secret" {
  value     = aws_iam_access_key.tf-cloud.secret
  sensitive = true
}
