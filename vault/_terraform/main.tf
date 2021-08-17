module "vault" {
  source              = "git@github.com:xxxxxxxxx/terraform-aws-packer-build.git"
  region              = var.region
  azs                 = var.azs
  trusted_networks    = var.trusted_networks
  cidr_block          = var.cidr_block
  s3_endpoint_enabled = var.s3_endpoint_enabled
}