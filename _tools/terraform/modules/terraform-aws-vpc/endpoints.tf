#----------------------------------
# VPC Endpoints
#----------------------------------
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
