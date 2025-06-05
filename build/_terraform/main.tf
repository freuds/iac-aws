module "build" {
  source              = "../../../_tools/terraform/modules/terraform-aws-packer-build"
  region              = var.region
  azs                 = var.azs
  trusted_networks    = var.trusted_networks
  cidr_block          = var.cidr_block
  s3_endpoint_enabled = var.s3_endpoint_enabled
  ssh_port            = var.ssh_port
}

module "kms" {
  source = "../../../_tools/terraform/modules/terraform-aws-kms"

  description           = "KMS key for AMI sharing"
  enable_default_policy = true
  key_users = [
    module.build.aws_iam_role_arn
  ]

  aliases = [
    "alias/ami_kms_share"
  ]
}
