variable "template" {
  type        = string
  default     = ""
  description = "Folder contains template pkr.hcl files"
}

variable "PROJECT_CI" {
  type    = string
  default = "https://github.com/freuds/iac-aws.git"
}

variable "PROJECT_ENV" {
  type    = string
  default = "QA"
}

variable "PROJECT_GIT" {
  type    = string
  default = "https://github.com/freuds/iac-aws.git"
}

variable "PROJECT_NAME" {
  type    = string
  default = "IAC-AWS"
}

variable "PROJECT_OWNER" {
  type    = string
  default = "frederic.willien@revolve.team"
}

variable "profile" {
  type    = string
  default = "revolve"
}

variable "box_base_mac" {
  type    = string
  default = "undefined"
}

variable "box_checksum" {
  type    = string
  default = "undefined"
}

variable "box_folder" {
  type    = string
  default = "undefined"
}

variable "box_name" {
  type    = string
  default = "bento/debian-10"
}

variable "box_version" {
  type    = string
  default = "202105.25.0"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "inventory_groups" {
  type = string
}

variable "playbook_file" {
  type = string
}

variable "region" {
  type    = string
  default = "eu-west-1"
}

variable "role" {
  type = string
}

variable "security_group_id" {
  type    = string
  default = "sg-0cedabc8df636164f"
}

variable "service" {
  type = string
}

variable "shared_account" {
  type = list(string)
  default = [
    "205168111441",
    "432161212492"
  ]
}

variable "source_ami" {
  type    = string
  default = "ami-0874dad5025ca362c"
}

variable "subnet_id" {
  type    = string
  default = "subnet-0d969f189aad02f1a"
}

variable "vagrant_ssh_private_key" {
  type    = string
  default = ""
}

variable "vpc_id" {
  type    = string
  default = "vpc-0943350383762ea0c"
}

variable "skip_create_ami" {
  type    = bool
  default = false
}