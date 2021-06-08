resource "aws_vpc" "build" {
  cidr_block           = var.cidr_block
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames
  tags                 = {
    Name  = "build-vpc"
    Stack = "build"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.build.id
  for_each                = toset(lookup(var.azs, var.region))
  cidr_block              = cidrsubnet(var.cidr_block, var.subnet_bits, index(lookup(var.azs, var.region), each.key))
  availability_zone       = each.key
  map_public_ip_on_launch = "true"
  tags                    = {
    Name  = "build-pub-subnet-${index(lookup(var.azs, var.region), each.key)}"
    Stack = "build"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.build.id
  tags   = {
    Name  = "build-igw"
    Stack = "build"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.build.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags   = {
    Name  = "build-pub-rt"
    Stack = "build"
  }
}

resource "aws_route_table_association" "rtap" {
  for_each       = toset(lookup(var.azs, var.region))
  subnet_id      = element([for o in aws_subnet.public : o.id], index(lookup(var.azs, var.region), each.key))
  route_table_id = aws_route_table.public.id
}

# Declare the data source
data "aws_vpc_endpoint_service" "s3" {
  count        = var.s3_endpoint_enabled ? 1 : 0
  service      = "s3"
  service_type = "Gateway"
}

# Create a VPC endpoint
resource "aws_vpc_endpoint" "s3" {
  count        = var.s3_endpoint_enabled ? 1 : 0
  vpc_id       = aws_vpc.build.id
  service_name = data.aws_vpc_endpoint_service.s3[count.index].service_name
  tags   = {
    Name  = "build-s3-endpoint"
    Stack = "build"
  }
}

# Associate VPC endpoint with route table a
resource "aws_vpc_endpoint_route_table_association" "s3-rt-public" {
  count           = var.s3_endpoint_enabled ? 1 : 0
  vpc_endpoint_id = aws_vpc_endpoint.s3[count.index].id
  route_table_id  = aws_route_table.public.id
}

resource "aws_security_group" "packer" {
  name        = "sgp-packer"
  description = "SG used by EC2 instances being packerized (aws-ebs builder only)"
  vpc_id      = aws_vpc.build.id
  ingress {
    from_port   = 22
    protocol    = "TCP"
    to_port     = 22
    cidr_blocks = var.trusted_networks
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  tags        = {
    Name  = "sgp-packer"
    Stack = "build"
  }
}