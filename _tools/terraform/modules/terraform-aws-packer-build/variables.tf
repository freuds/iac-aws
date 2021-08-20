variable "region" {
  default = "eu-west-1"
}

variable "azs" {
  type = map(list(string))
  default = {
    "eu-west-1" = [
      "eu-west-1a"
    ]
  }
}

variable "cidr_block" {
  type    = string
  default = "10.110.0.0/20"
}

variable "subnet_bits" {
  type    = number
  default = 4
}
variable "enable_dns_support" {
  type    = bool
  default = true
}

variable "enable_dns_hostnames" {
  type    = bool
  default = true
}

variable "trusted_networks" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "s3_endpoint_enabled" {
  type    = bool
  default = false
}

variable "ssh_port" {
  type    = number
  default = 22
}