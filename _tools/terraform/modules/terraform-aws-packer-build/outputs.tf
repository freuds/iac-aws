output "vpc_id" {
  value = aws_vpc.build.id
}

output "public_subnets" {
  value = [for s in aws_subnet.public : s.id]
}

output "security_group_public_subnet" {
  value = aws_security_group.packer.id
}

output "aws_iam_role_arn" {
  value = aws_iam_role.packer_build.arn
}
