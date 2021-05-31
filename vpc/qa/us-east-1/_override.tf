module "vpc" {
  source = "../../../_tools/terraform/modules/terraform-aws-vpc"
}

# module "bastion" {
#   source = "../../../_tools/terraform/modules/terraform-aws-bastion"
# }