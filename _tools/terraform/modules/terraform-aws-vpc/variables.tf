variable "region" {}
variable "env" {}
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
  }
}

variable "r53_ttl" {
  default = 300
}

variable "multi_nat_enabled" {
  default = false
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