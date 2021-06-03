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
variable "internal_domain_name" {}
variable "external_domain_name" {}

variable "subnet_pub_tags" {
  default = {}
  description = "Tags for public subnet"
}

variable "subnet_priv_tags" {
  default = {}
  description = "Tags for private subnet"
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
