output "saml-login" {
  value = <<EOF
[DEFAULT]
idp_url = https://${var.auth0_domain}
client_id = ${auth0_client.auth0-cli.client_id}

[${var.admin_role_name}@${aws_iam_account_alias.current.account_alias}]
idp_url = https://${var.auth0_domain}
client_id = ${auth0_client.auth0-cli.client_id}
aws_profile = ${var.admin_role_name}@${aws_iam_account_alias.current.account_alias}
aws_role = ${var.admin_role_name}
aws_account = ${aws_iam_account_alias.current.account_alias}

[${var.user_role_name}@${aws_iam_account_alias.current.account_alias}]
idp_url = https://${var.auth0_domain}
client_id = ${auth0_client.auth0-cli.client_id}
aws_profile = ${var.user_role_name}@${aws_iam_account_alias.current.account_alias}
aws_role = ${var.user_role_name}
aws_account = ${aws_iam_account_alias.current.account_alias}

EOF
}

output "aws-accounts" {
  value = <<EOF
[DEFAULT]
${aws_iam_account_alias.current.account_alias} = ${data.aws_caller_identity.current.account_id}
EOF
}

output "aws-config" {
  value = <<EOF
[profile ${var.admin_role_name}@${aws_iam_account_alias.current.account_alias}]
region=${var.region}
output=json

[profile ${var.user_role_name}@${aws_iam_account_alias.current.account_alias}]
region=${var.region}
output=json
EOF
}

output "root_keypair" {
  value = aws_key_pair.key_pair.key_name
}

output "s3_vault_bucket" {
  value = aws_s3_bucket.vault.bucket
}

output "admin_role_arn" {
  value = aws_iam_role.admin.arn
}

output "user_role_arn" {
  value = aws_iam_role.user.arn
}