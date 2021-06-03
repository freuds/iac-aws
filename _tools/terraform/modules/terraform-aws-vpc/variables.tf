variable "env" {
  type = string
  default = ""
  description = "Environment"
}

variable "region" {
  type = string
  default = "eu-west-1"
  description = "Region selected"
}

variable "cidr_block" {
  description = "CIDR block for VPC"
}

variable "subnet_priv_bits" {
  default = 4
  description = "Tell how bits are added from CIDR for private subnet"
}

variable "subnet_pub_bits" {
  default = 6
  description = "Tell how bits are added from CIDR for public subnet"
}

variable "subnet_pub_offset" {}

variable "internal_domain_name" {
  type = string
  default = ""
  description = "DNS domain name for zone private"
}

variable "external_domain_name" {
  type = string
  default = ""
  description = "DNS domain name for zone public"
}

variable "azs" {
  description = "List of all AZs per region available"
  type = map(list(string))
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
  description = "Time To Live : DNS timeout"
}

variable "one_nat_gateway_per_az" {
  default     = false
  description = "Define if we created one NAT GW per AZ available or not"
}

variable "subnet_pub_tags" {
  default = {}
  description = "Tags for public subnet"
}

variable "subnet_priv_tags" {
  default = {}
  description = "Tags for private subnet"
}

variable "s3_endpoint_enabled" {
  default = true
}

variable "dynamodb_endpoint_enabled" {
  default = true
}