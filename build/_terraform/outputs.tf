output "vpc_id" {
  value = module.build.vpc_id
}

output "public_subnets" {
  value = module.build.public_subnets
}

output "security_group_public_subnet" {
  value = module.build.sg_public_subnet
}