output "vpc_id" {
  value = module.vpc.vpc_id
}

# output "db_subnet_group" {
#   value = module.vpc.db_subnet_group
# }

# output "elasticache_subnet_group" {
#   value = module.vpc.elasticache_subnet_group
# }

output "azs" {
  value = module.vpc.azs
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "r53_private_zone" {
  value = module.vpc.private_host_zone
}

output "private_domain" {
  value = module.vpc.private_domain_name
}

output "public_domain" {
  value = module.vpc.public_domain_name
}

# output "vpc_dns_srv_ip" {
#   value = module.vpc.vpc_dns_srv_ip
# }

# output "bastion_sg" {
#   value = module.bastion.bastion_sg
# }

# output "ssh_from_bastion" {
#   value = module.bastion.ssh_from_bastion
# }

# output "ssl_cert_arn" {
#   value = module.vpc.ssl_cert_arn
# }

# output "ssl_prod_arn" {
#   value = module.vpc.prod_ssl_cert_arn
# }