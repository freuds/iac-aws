module "vpc" {
  source                 = "../../../_tools/terraform/modules/terraform-aws-vpc"
  env                    = var.env
  region                 = var.region
  cidr_block             = var.cidr_block
  subnet_priv_bits       = var.subnet_priv_bits
  subnet_pub_bits        = var.subnet_pub_bits
  subnet_pub_offset      = var.subnet_pub_offset
  subnet_priv_tags       = var.subnet_priv_tags
  subnet_pub_tags        = var.subnet_pub_tags
  internal_domain_name   = var.internal_domain_name
  external_domain_name   = var.external_domain_name
  one_nat_gateway_per_az = var.one_nat_gateway_per_az

  cf_certificate_enabled = var.cf_certificate_enabled
}

#----------------------------
# Gandi DNS
#----------------------------
module "gandi-dns" {
  source                      = "../../../_tools/terraform/modules/terraform-gandi-dns"
  gandi_personal_access_token = var.PERSONAL_ACCESS_TOKEN
  gandi_domain_name           = var.gandi_domain_name
  gandi_alias_ns              = var.gandi_alias_ns
  gandi_aws_ns                = [for ns in module.vpc.public_name_servers : format("%s.", ns)]
}

#----------------------------
# Bastion
#----------------------------
# module "bastion" {
#   source                     = "git@github.com:example/terraform-aws-bastion.git"
#   region                     = var.region
#   env                        = var.env
#   vpc_id                     = module.vpc.vpc_id
#   ami                        = var.bastion_ami
#   instance_type              = var.bastion_instance_type
#   asg_desired_capacity       = var.bastion_asg_desired_capacity
#   asg_min_size               = var.bastion_asg_min_size
#   asg_max_size               = var.bastion_asg_max_size
#   aws_route53_zone_public_id = module.vpc.public_host_zone
#   subnet_ids                 = module.vpc.public_subnets
#   extra_userdata             = data.template_file.extra-userdata.rendered
#   root_keypair               = var.root_keypair
#   bastion_enabled            = var.bastion_enabled
#   ssh_port                   = var.ssh_port
#   # s3_vault_bucket            = data.terraform_remote_state.baseline.outputs.s3-vault-bucket
# }

# data "template_file" "extra-userdata" {
#   template = file("${path.cwd}/../../_terraform/init.tpl")

#   # vars = {
#   #   db_script      = data.template_file.db-import.rendered
# }

# data "template_file" "db-import" {
#   template = file("${path.cwd}/../../_terraform/db-import.sh.tpl")

#   vars = {
#     db_host     = var.db_host
#     db_user     = var.db_user
#     db_password = var.db_password
#     db_name     = var.db_name
#   }
# }
