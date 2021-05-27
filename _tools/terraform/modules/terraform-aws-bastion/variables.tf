variable "service" {
  default = "bastion"
}

variable "ami" {
}

variable "env" {
}

variable "role" {
  default = "server"
}
variable "instance_type" {
  default = "t3.micro"
}

variable "user_data_file" {
  default = "user_data.sh"
}

variable "region" {
  default = "eu-west-1"
}

variable "azs" {
  type    = list(string)
  default = []
}

variable "vpc_id" {
}

variable "cidr_blocks" {
  type    = list(string)
  default = [
    "0.0.0.0/0",
  ]
}

variable "extra_userdata" {
  description = "The additional userdata script to execute on Bastion VMs first boot"
  default     = ""
}

variable "asg_desired_capacity" {
  type    = number
  default = 1
}

variable "asg_min_size" {
  type    = number
  default = 1
}

variable "asg_max_size" {
  type    = number
  default = 1
}

variable "ssh_port" {
  type    = number
  default = 22
}

variable "outbound_port" {
  default = 0
}

variable "outbound_cidr_blocks" {
  default = [
    "0.0.0.0/0"]
}

variable "r53_pub_ttl" {
  default = 300
}

variable "aws_route53_zone_public_id" {
  default = ""
}

variable "subnet_ids" {
  type    = list(string)
  default = []
}

variable "s3_vault_bucket" {
}

variable "root_keypair" {
}