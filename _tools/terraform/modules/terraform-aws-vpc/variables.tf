variable "env" {
  type = string
  default = ""
}

variable "region" {
  type = string
  default = "eu-west-1"
}

variable "cidr_block" {}
variable "subnet_priv_bits" {}
variable "subnet_pub_bits" {}
variable "subnet_pub_offset" {}
variable "internal_domain_name" {}
variable "external_domain_name" {}

variable "azs" {
  type    = map(list(string))
  default = {
    eu-west-1 = [
      "eu-west-1a",
      "eu-west-1b",
      "eu-west-1c"]
    us-east-1 = [
      "us-east-1a",
      "us-east-1b",
      "us-east-1c",
      "us-east-1d",
      "us-east-1e",
      "us-east-1f"]
  }
}

variable "r53_ttl" {
  default = 300
}

variable "multi_nat_enabled" {
  default = false
  description = "Define if we created one NAT GW per AZ available or not"
}

variable "s3_endpoint_enabled" {
  default = true
}

variable "dynamodb_endpoint_enabled" {
  default = true
}

variable "eks_public_subnet_tags" {
  default = {}
}

variable "eks_private_subnet_tags" {
  default = {}
}