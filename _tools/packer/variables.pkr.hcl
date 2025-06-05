# All generated input variables will be of 'string' type as this is how Packer JSON
# views them; you can change their type later on. Read the variables type
# constraints documentation
# https://www.packer.io/docs/templates/hcl_templates/variables#type-constraints for more info.

# locals blocks
locals {
  version_number       = formatdate("YYYYMMDDhhmm", timestamp())
}

# variables
variable "build_directory" {
  type    = string
  default = "./output"
}

variable "cpus" {
  type    = string
  default = "2"
}

variable "memory" {
  type    = string
  default = "512"
}

variable "disk_size" {
  type    = string
  default = "1024"
}

#---------------------------------------
# AWS variables (shared between builders
#---------------------------------------
variable "aws_region" {
  type    = string
  default = "eu-west-1"
}

variable "aws_instance_type" {
  type    = string
  default = "t3.medium"
}

variable "aws_source_ami_centos-79" {
  type    = string
  default = "ami-0ffc7af9c06de0077"
}

variable "aws_source_ami_centos-83" {
  type    = string
  default = "ami-0c8ad4b0ff2d20c79"
}

variable "aws_source_ami_redhat-79" {
  type    = string
  default = "ami-00d05da9ad5c69bfd"
}

variable "aws_source_ami_redhat-83" {
  type    = string
  default = "ami-02a403e9f22ebf62b"
}

variable "aws_source_ami_ubuntu-1804" {
  type    = string
  default = "ami-0bd1a64868721e9ef"
}

variable "aws_source_ami_ubuntu-2004" {
  type    = string
  default = "ami-0b9e641f013a385af"
}

variable "aws_subnet_name" {
  type    = string
  default = ""
  description = "Tag Name of the subnet to use"
}

variable "aws_vpc_name" {
  description = "Tag Name of the VPC"
  type    = string
  default = ""
}

variable "aws_security_group_filter" {
  description = "Tag Name of the security group to use"
  type    = string
  default = ""
}

variable "aws_kms_key_id" {
  type    = string
  default = ""
}

#---------------------------------------
# Common variables
#---------------------------------------
variable "os_family" {
  type    = string
  default = "linux"
}

variable "os_name" {
  type    = string
  default = "ubuntu"
}

variable "os_version" {
  type    = string
  default = "22.04"
}

variable "role" {
  type = string
}

variable "service" {
  type = string
}

variable "project_ci" {
  type    = string
  default = ""
}

variable "project_env" {
  type    = string
  default = "QA"
}

variable "project_git" {
  type    = string
  default = ""
}

variable "project_name" {
  type    = string
  default = ""
}

variable "project_owner" {
  type    = string
  default = ""
}

variable "image_version_number" {
  type    = string
  default = "1970.01.010000"
}

#---------------------------------------
# Ansible variables
#---------------------------------------
variable "inventory_groups" {
  description = "List of inventory groups for Ansible"
  type    = string
  default = ""
}

variable "playbook_file" {
  description = "Ansible playbook file to run"
  type    = string
  default = ""
}
