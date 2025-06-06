output "vpc_id" {
  value = module.build.vpc_id
}

output "public_subnets" {
  value = module.build.public_subnets
}

output "security_group_public_subnet" {
  value = module.build.security_group_public_subnet
}

output "aws_iam_role_arn" {
  value = module.build.aws_iam_role_arn
}
