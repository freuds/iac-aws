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

variable "eks_public_subnet_tags" {
  default = {}
}

variable "eks_private_subnet_tags" {
  default = {}
}

variable "one_nat_gateway_per_az" {
  default = false
  description = "Define if we created one NAT GW per AZ available or not"
}

variable "bastion_ami" {
  default = "ami-2547a34c"
}

variable "bastion_instance_type" {
  default = "t3.micro"
}
variable "bastion_asg_desired_capacity" {
  type    = number
  default = 1
}
variable "bastion_asg_min_size" {
  type    = number
  default = 1
}
variable "bastion_asg_max_size" {
  type    = number
  default = 1
}

variable "db_name" {
  type    = string
  default = "database"
}
