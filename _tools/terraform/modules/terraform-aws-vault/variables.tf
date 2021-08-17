variable "env" {
  default = "qa"
}

variable "region" {
  default = "eu-west-1"
}

variable "vault_url" {
  default = "https://releases.hashicorp.com/vault/1.6.0/vault_1.6.0_linux_amd64.zip"
}

// variable "vpc_cidr" {
//   type        = string
//   description = "CIDR of the VPC"
//   default     = "192.168.100.0/24"
// }