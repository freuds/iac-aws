####################################
# VPC
####################################
resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = "true"
  enable_dns_support   = "true"

  tags = {
    Name = format("%s-vpc", var.env)
  }
}

####################################
# Public subnets
####################################
resource "aws_subnet" "public" {
  for_each                = toset(lookup(var.azs, var.region))
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.cidr_block, var.subnet_pub_bits, var.subnet_pub_offset + index(lookup(var.azs, var.region), each.key))
  availability_zone       = each.key
  map_public_ip_on_launch = "true"
  tags = merge(
    {
      Name        = format("%s-pub-subnet-%s", var.env, trimprefix(each.key, var.region)),
      Environment = var.env
    },
    var.subnet_pub_tags,
  )
}

####################################
# Ressources for Publics subnets
####################################
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = format("%s-igw", var.env),
    Environment = var.env
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = format("%s-pub-rt", var.env),
    Environment = var.env
  }
}

resource "aws_route" "public-default" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

resource "aws_route_table_association" "rta-pub" {
  for_each       = toset(lookup(var.azs, var.region))
  subnet_id      = element([for o in aws_subnet.public : o.id], index(lookup(var.azs, var.region), each.key))
  route_table_id = aws_route_table.public.id
}

####################################
# Zone Public Route53
####################################
resource "aws_route53_zone" "public" {
  name = var.external_domain_name
}

####################################
# Single-NAT-GW : EIP
####################################
resource "aws_eip" "single-eip" {
  count = !var.one_nat_gateway_per_az ? 1 : 0
  tags = {
    Name        = format("%s-eip", var.env),
    Environment = var.env
  }
}

####################################
# Single-NAT-GW :
####################################
resource "aws_nat_gateway" "single-natgw" {
  count         = !var.one_nat_gateway_per_az ? 1 : 0
  allocation_id = aws_eip.single-eip[count.index].id
  subnet_id     = aws_subnet.public[element(lookup(var.azs, var.region), 0)].id
  tags = {
    Name        = format("%s-natgw-%s", var.env, trimprefix(element(lookup(var.azs, var.region), 0), var.region)),
    Environment = var.env
  }
}

####################################
# Single-NAT-GW : Record DNS
####################################
resource "aws_route53_record" "single-natgw-record" {
  count   = !var.one_nat_gateway_per_az ? 1 : 0
  zone_id = aws_route53_zone.public.id
  name    = "natgw"
  type    = "A"
  ttl     = var.r53_ttl
  records = [
    aws_nat_gateway.single-natgw[count.index].public_ip
  ]
}

####################################
# Multi-NAT-GW : EIP
####################################
resource "aws_eip" "multi-eip" {
  for_each = var.one_nat_gateway_per_az ? toset(lookup(var.azs, var.region)) : []
  tags = {
    Name        = format("%s-eip-%s", var.env, trimprefix(each.key, var.region)),
    Environment = var.env
  }
}

####################################
# Multi-NAT-GW :
####################################
resource "aws_nat_gateway" "multi-natgw" {

  for_each      = var.one_nat_gateway_per_az ? toset(lookup(var.azs, var.region)) : []
  allocation_id = aws_eip.multi-eip[each.key].id
  subnet_id     = element([for o in aws_subnet.public : o.id], index(lookup(var.azs, var.region), each.key))

  tags = {
    Name        = format("%s-natgw-%s", var.env, trimprefix(each.key, var.region)),
    Environment = var.env
  }

  lifecycle {
    create_before_destroy = true
  }
}

####################################
# Multi-NAT-GW : records public
####################################
resource "aws_route53_record" "multi-natgw-record" {

  for_each = var.one_nat_gateway_per_az ? toset(lookup(var.azs, var.region)) : []
  zone_id  = aws_route53_zone.public.id
  name     = format("natgw-%s", trimprefix(each.key, var.region))
  type     = "A"
  ttl      = var.r53_ttl
  records = [
    aws_nat_gateway.multi-natgw[each.value].public_ip
  ]
}

####################################
# Private subnets
####################################
resource "aws_subnet" "private" {
  for_each                = toset(lookup(var.azs, var.region))
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.cidr_block, var.subnet_priv_bits, index(lookup(var.azs, var.region), each.key))
  availability_zone       = each.key
  map_public_ip_on_launch = "false"
  tags = merge(
    {
      Name        = format("%s-priv-subnet-%s", var.env, trimprefix(each.key, var.region)),
      Environment = var.env
    },
    var.subnet_priv_tags,
  )
}

####################################
# Private route table
####################################
resource "aws_route_table" "private" {
  for_each = toset(lookup(var.azs, var.region))
  vpc_id   = aws_vpc.main.id

  tags = {
    Name        = format("%s-priv-rt-%s", var.env, trimprefix(each.key, var.region)),
    Environment = var.env
  }
}
####################################
# Private route table association
####################################
resource "aws_route_table_association" "rta-prv" {
  for_each       = toset(lookup(var.azs, var.region))
  subnet_id      = element([for o in aws_subnet.private : o.id], index(lookup(var.azs, var.region), each.key))
  route_table_id = aws_route_table.private[each.value].id
}

####################################
# Private route
####################################
resource "aws_route" "private-default" {
  for_each               = toset(lookup(var.azs, var.region))
  route_table_id         = aws_route_table.private[each.value].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = var.one_nat_gateway_per_az ? aws_nat_gateway.multi-natgw[each.value].id : aws_nat_gateway.single-natgw.0.id
}

resource "aws_route53_zone" "private" {
  name = var.internal_domain_name
  vpc {
    vpc_id = aws_vpc.main.id
  }
}

####################################
# VPC Endpoints
####################################
resource "aws_vpc_endpoint" "s3" {
  count        = var.s3_endpoint_enabled ? 1 : 0
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.${var.region}.s3"
  route_table_ids = concat([
  aws_route_table.public.id], [for o in aws_route_table.private : o.id])
  tags = {
    Environment = var.env,
    Service     = "S3",
    Stack       = "common",
    Role        = "endpoint"
  }
}

resource "aws_vpc_endpoint" "dynamodb" {
  count        = var.dynamodb_endpoint_enabled ? 1 : 0
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.${var.region}.dynamodb"
  route_table_ids = concat([
  aws_route_table.public.id], [for o in aws_route_table.private : o.id])
  tags = {
    Environment = var.env,
    Service     = "DynamoDB",
    Stack       = "common",
    Role        = "endpoint"
  }
}

resource "aws_vpc_endpoint" "lambda" {
  count               = var.lambda_endpoint_enabled ? 1 : 0
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.region}.lambda"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  security_group_ids = [
    aws_security_group.allow-lambda.id,
  ]
  subnet_ids = [for o in aws_subnet.private : o.id]

  tags = {
    Environment = var.env,
    Service     = "Lambda",
    Stack       = "common",
    Role        = "endpoint"
  }
}

//----------------------------
# SG bastion ssh egress
//----------------------------
resource "aws_security_group" "allow-lambda" {
  name        = "sgp-allow-lambda"
  vpc_id      = aws_vpc.main.id
  description = "Security group for lambda interface VPC"
  ingress {
    from_port   = var.inbound_port
    to_port     = var.inbound_port
    protocol    = "-1"
    cidr_blocks = var.inbound_cidr_blocks
  }
  egress {
    from_port   = var.outbound_port
    to_port     = var.outbound_port
    protocol    = "-1"
    cidr_blocks = var.outbound_cidr_blocks
  }
  tags = {
    Name        = "sgp-allow-lambda",
    Environment = var.env
  }
  lifecycle {
    create_before_destroy = true
  }
}

##
# ElastiCache subnets
##
# resource "aws_elasticache_subnet_group" "ec-subnet-group" {
#   name        = "${var.env}-ec-subnet-group"
#   description = "Elastic Cache Subnet Group"
#   subnet_ids  = [for o in aws_subnet.private : o.id]
# }

##
# RDS subnets
##
# resource "aws_db_subnet_group" "db-subnet-group" {
#   name        = "${var.env}-db-subnet-group"
#   description = "RDS DB Subnet Group"
#   subnet_ids  = [for o in aws_subnet.private : o.id]

#   tags = {
#     Name = "${var.env}-db-subnet-group"
#   }
# }

