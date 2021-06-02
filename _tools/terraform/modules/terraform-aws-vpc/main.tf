##
# VPC
##
resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = "true"
  enable_dns_support   = "true"

  tags = {
    Name = "${var.env}-vpc"
  }
}

##
# Public subnets
##
resource "aws_subnet" "public" {
  for_each                = toset(lookup(var.azs, var.region))
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.cidr_block, var.subnet_pub_bits, var.subnet_pub_offset +index(lookup(var.azs, var.region), each.key))
  availability_zone       = each.key
  map_public_ip_on_launch = "true"
  tags = merge(
    {
      "Name" = format("%s-pub-subnet-%s", var.env, trimprefix(each.key, var.region))
    },
    var.eks_public_subnet_tags,
  )
}

##
# Ressources for Publics subnets
##
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = format("%s-igw", var.env)
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = format("%s-pub-rt", var.env),
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

##
# Private subnets
##
# resource "aws_subnet" "private" {
#   for_each                = toset(lookup(var.azs, var.region))
#   vpc_id                  = aws_vpc.main.id
#   cidr_block              = cidrsubnet(var.cidr_block, var.subnet_priv_bits, index(lookup(var.azs, var.region), each.key))
#   availability_zone       = each.key
#   map_public_ip_on_launch = "false"
#     tags = merge(
#     {
#       "Name" = format("%s-pub-subnet-%s", var.env, trimprefix(each.key, var.region))
#     },
#     var.eks_private_subnet_tags,
#   )
# }



##
# Zone Public Route53
##
resource "aws_route53_zone" "public" {
  name = var.external_domain_name
}

####################################
# Multi-NAT-GW : EIP
####################################
resource "aws_eip" "eip-multi" {
  for_each       = var.multi_nat_enabled ? toset(lookup(var.azs, var.region)) : []
  tags  = {
    Name = format("%s-eip-%s", var.env, trimprefix(each.key, var.region)),
    Environment = var.env
  }
}

####################################
# Multi-NAT-GW :
####################################
resource "aws_nat_gateway" "nat-gw-multi" {

  for_each       = var.multi_nat_enabled ? toset(lookup(var.azs, var.region)) : []
  allocation_id  = aws_eip.eip-multi[each.key].id
  subnet_id      = element([for o in aws_subnet.public : o.id], index(lookup(var.azs, var.region), each.key))

  lifecycle {
    create_before_destroy = true
  }
  tags  = {
    "Name" = format("%s-natgw-%s", var.env, trimprefix(each.key, var.region)),
    "Environment" = var.env
  }
}

####################################
# Multi-NAT-GW : records public
####################################
resource "aws_route53_record" "nat-gw-multi-record" {

  for_each = var.multi_nat_enabled ? toset(lookup(var.azs, var.region)) : []
  zone_id = aws_route53_zone.public.id
  name    = format("natgw-%s", trimprefix(each.key, var.region))
  type    = "A"
  ttl     = var.r53_ttl
  records = [
    aws_nat_gateway.nat-gw-multi[each.value].public_ip
  ]
}

####################################
# Single-NAT-GW : EIP
####################################
resource "aws_eip" "eip-single" {
  count = !var.multi_nat_enabled ? 1 : 0
  tags  = {
    "Name" = format("%s-eip", var.env),
    "Environment" = var.env
  }
}

####################################
# Single-NAT-GW :
####################################
resource "aws_nat_gateway" "nat-gw" {
  count         = !var.multi_nat_enabled ? 1 : 0
  allocation_id = aws_eip.eip-single[count.index].id
  subnet_id     = aws_subnet.public[element(lookup(var.azs, var.region), 0)].id
  tags  = {
    "Name" = format("%s-natgw-%s", var.env, trimprefix(element(lookup(var.azs, var.region), 0), var.region)),
    "Environment" = var.env
  }
}

####################################
# Single-NAT-GW : Record DNS
####################################
resource "aws_route53_record" "nat-gw-record" {
  count   = !var.multi_nat_enabled ? 1 : 0
  zone_id = aws_route53_zone.public.id
  name    = "natgw"
  type    = "A"
  ttl     = var.r53_ttl
  records = [
    aws_nat_gateway.nat-gw[count.index].public_ip
    ]
}


# resource "aws_route" "private-nat-default" {
#   count                  = !var.multi_nat_enabled ? length(lookup(var.azs, var.region)) : 0
#   route_table_id         = aws_route_table.private[element(lookup(var.azs, var.region), count.index)].id
#   destination_cidr_block = "0.0.0.0/0"
#   nat_gateway_id         = aws_nat_gateway.nat-gw.0.id
# }

##
# Public records for nat gateway
##
# resource "aws_route53_record" "nat-gw-record-a" {
#   count   = var.multi_nat_enabled ? 1 : 0
#   zone_id = aws_route53_zone.public.id
#   name    = "natgw-a"
#   type    = "A"
#   ttl     = var.r53_ttl
#   records = [
#     aws_nat_gaeway.nat-gw-a[count.index].public_ip]
# }

# resource "aws_route53_record" "nat_gw_record_b" {
#   count   = var.multi_nat_enabled ? 1 : 0
#   zone_id = aws_route53_zone.public.id
#   name    = "natgw-b"
#   type    = "A"
#   ttl     = var.r53_ttl
#   records = [
#     aws_nat_gateway.nat-gw-b[count.index].public_ip]
# }

# resource "aws_route53_record" "nat_gw_record_c" {
#   count   = var.multi_nat_enabled ? 1 : 0
#   zone_id = aws_route53_zone.public.id
#   name    = "natgw-c"
#   type    = "A"
#   ttl     = var.r53_ttl
#   records = [
#     aws_nat_gateway.nat-gw-c[count.index].public_ip]
# }

# resource "aws_route_table" "private" {
#   for_each = toset(lookup(var.azs, var.region))
#   vpc_id   = aws_vpc.main.id

#   tags = {
#     Name        = "${var.env}-vpc-priv-rt-${trimprefix(each.key, var.region)}",
#     Environment = var.env
#   }
# }

# resource "aws_route" "private-nat-a" {
#   count                  = var.multi_nat_enabled ? 1 : 0
#   route_table_id         = aws_route_table.private[element(lookup(var.azs, var.region), 0)].id
#   destination_cidr_block = "0.0.0.0/0"
#   nat_gateway_id         = aws_nat_gateway.nat-gw-a[count.index].id
# }

# resource "aws_route" "private-nat-b" {
#   count                  = var.multi_nat_enabled ? 1 : 0
#   route_table_id         = aws_route_table.private[element(lookup(var.azs, var.region), 1)].id
#   destination_cidr_block = "0.0.0.0/0"
#   nat_gateway_id         = aws_nat_gateway.nat-gw-b[count.index].id
# }

# resource "aws_route" "private-nat-c" {
#   count                  = var.multi_nat_enabled ? 1 : 0
#   route_table_id         = aws_route_table.private[element(lookup(var.azs, var.region), 2)].id
#   destination_cidr_block = "0.0.0.0/0"
#   nat_gateway_id         = aws_nat_gateway.nat-gw-c[count.index].id
# }

# resource "aws_route_table_association" "rta-prv" {
#   for_each       = toset(lookup(var.azs, var.region))
#   subnet_id      = aws_subnet.private[element(lookup(var.azs, var.region), index(lookup(var.azs, var.region), each.key))].id
#   route_table_id = aws_route_table.private[element(lookup(var.azs, var.region), index(lookup(var.azs, var.region), each.key))].id
# }

# resource "aws_route53_zone" "private" {
#   name = var.internal_domain_name
#   vpc {
#     vpc_id = aws_vpc.main.id
#   }
# }



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





# resource "aws_vpc_endpoint" "s3" {
#   count           = var.s3_endpoint_enabled ? 1 : 0
#   vpc_id          = aws_vpc.main.id
#   service_name    = "com.amazonaws.${var.region}.s3"
#   route_table_ids = concat([
#     aws_route_table.public.id], [for o in aws_route_table.private : o.id])
#   tags            = {
#     Environment = var.env,
#     Service     = "S3",
#     Stack       = "common",
#     Role        = "endpoint"
#   }
# }

# resource "aws_vpc_endpoint" "dynamodb" {
#   count           = var.dynamodb_endpoint_enabled ? 1 : 0
#   vpc_id          = aws_vpc.main.id
#   service_name    = "com.amazonaws.${var.region}.dynamodb"
#   route_table_ids = concat([
#     aws_route_table.public.id], [for o in aws_route_table.private : o.id])
#   tags            = {
#     Environment = var.env,
#     Service     = "DynamoDB",
#     Stack       = "common",
#     Role        = "endpoint"
#   }
# }