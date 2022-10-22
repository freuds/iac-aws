module "vpc" {
  source                 = "git@github.com:xxxxxxxxxxxxxx/terraform-aws-vpc.git"
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

# module "gandi-dns" {
#   source            = "git@github.com:xxxxxxxxxxxxxx/terraform-gandi-dns.git"
#   gandi_api_key     = var.GANDI_API_KEY
#   gandi_domain_name = var.gandi_domain_name
#   gandi_alias_ns    = var.gandi_alias_ns
#   gandi_aws_ns      = [for ns in module.vpc.public_name_servers : format("%s.", ns)]
# }

# module "bastion" {
#   source                     = "git@github.com:xxxxxxxxxxxxxx/terraform-aws-bastion.git"
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
#   #   id_phenix_pub  = var.id_phenix_pub
#   #   id_phenix_priv = var.id_phenix_priv

#   #   datadog_api_key       = var.DATADOG_API_KEY
#   #   datadog_tag_env       = var.env
#   #   datadog_agent_enabled = var.datadog_agent_enabled
#   # }
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
