variable "env" {
  default = "qa"
}

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

// variable "cidr_block" {
//   type    = string
//   default = "10.110.0.0/20"
// }

// variable "trusted_networks" {
//   type    = list(string)
//   default = ["0.0.0.0/0"]
// }

// variable "s3_endpoint_enabled" {
//   type    = bool
//   default = false
// }