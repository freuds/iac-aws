variable "env" {
  type = string
}

variable "region" {
  type    = string
  default = "eu-west-1"
}

variable "service" {
  type    = string
  default = "efs"
}

variable "role" {
  type    = string
  default = "nfs"
}

variable "private_subnet_ids" {
  description = "ID list of private_subnets"
  type        = list(string)
  default     = []
}

variable "ingress_security_group_ids" {
  description = "ID list of security group for Ingress rule"
  type        = list(string)
  default     = []
}

variable "egress_security_group_ids" {
  description = "ID list of security group for Egress rule"
  type        = list(string)
  default     = []
}

variable "vpc_id" {
  type    = string
  default = "vpc_id"
}

variable "throughput_mode" {
  type    = string
  default = "bursting"
}

variable "performance_mode" {
  type    = string
  default = "generalPurpose"
}

variable "user_gid" {
  type    = number
  default = 1000
}

variable "user_uid" {
  type    = number
  default = 1000
}

variable "secondary_gids" {
  default = [
    0,
    82
  ]
}

variable "ap_root_dir_path" {
  description = "path exposed as root directory from efs"
  type        = string
  default     = "/"
}

variable "owner_gid" {
  description = "new root path owner gid"
  type        = number
  default     = 1000
}

variable "owner_uid" {
  description = "new root path owner uid"
  type        = number
  default     = 1000
}

variable "permissions" {
  description = "new root path permissions"
  type        = number
  default     = 777
}