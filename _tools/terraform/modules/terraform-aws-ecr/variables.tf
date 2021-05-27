variable "repository_name" {
  type    = string
  default = "ecr-repository"
}

variable "image_tag_mutability" {
  type    = string
  default = "IMMUTABLE"
}

variable "scan_on_push" {
  type    = string
  default = true
}

variable "env" {
  type = string
}

variable "service" {
  type    = string
  default = "ecr"
}

variable "role" {
  type    = string
  default = "repository"
}

variable "max_image_count" {
  type    = number
  default = 100
}

variable "authorized_eks_clusters_arn" {
  description = "ARM list of authorized EKS clusters"
  type        = list(string)
  default     = []
}