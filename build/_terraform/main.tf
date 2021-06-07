module "build" {
  source           = "git@github.com:xxxxxxxxx/terraform-aws-packer-build.git"
  region           = var.region
  azs              = var.azs
  trusted_networks = var.trusted_networks
  cidr_block       = var.cidr_block
}