output "vpc_id" {
  value = aws_vpc.main.id
}

output "azs" {
  value = var.azs
}

output "vpc_dns_srv_ip" {
  value = cidrhost(var.cidr_block, 2)
}

output "private_host_zone" {
  value = aws_route53_zone.private.id
}

output "public_host_zone" {
  value = aws_route53_zone.public.id
}

output "public_host_zone_id" {
  value = aws_route53_zone.public.zone_id
}

output "private_domain_name" {
  value = var.internal_domain_name
}

output "public_domain_name" {
  value = var.external_domain_name
}

output "public_subnets" {
  value = [for s in aws_subnet.public : s.id]
}

output "public_subnets_cidr" {
  value = [for b in aws_subnet.public : b.cidr_block]
}

output "private_subnets" {
  value = [for s in aws_subnet.private: s.id]
}

output "private_subnets_cidr" {
  value = [for b in aws_subnet.private : b.cidr_block]
}

output "db_subnet_group" {
  value = aws_db_subnet_group.db-subnet-group.name
}

output "elasticache_subnet_group" {
  value = aws_elasticache_subnet_group.ec-subnet-group.name
}

output "ssl_cert_arn" {
  value = aws_acm_certificate.cert.arn
}

locals {
  prod_ssl_cert_arn = var.env == "prod" ? data.aws_acm_certificate.prod.0.arn : ""
}

output "prod_ssl_cert_arn" {
  value = local.prod_ssl_cert_arn
}