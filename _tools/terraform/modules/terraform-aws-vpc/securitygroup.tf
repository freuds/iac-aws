#----------------------------------
# SG for Lambda
#----------------------------------
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
