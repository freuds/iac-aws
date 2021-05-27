variable "env" {
  type = string
}

variable "region" {
  type    = string
  default = "eu-west-1"
}

variable "service" {
  type    = string
  default = "kubernetes-efs"
}

variable "role" {
  type    = string
  default = "config"
}

variable "file_system_id" {
  type        = string
  default     = "file system id"
  description = "Filesystem ID from EFS"
}

variable "efs_dns_name" {
  type        = string
  default     = "efs dns name"
  description = "DNS name from EFS"
}

variable "reclaim_policy" {
  type    = string
  default = "Retain"
}

variable "pvc_storage_size" {
  type    = string
  default = "30Gi"
}

variable "pv_storage_size" {
  type    = string
  default = "30Gi"
}

variable "efs_access_point" {
  type    = string
  default = "efs_access_point"
}