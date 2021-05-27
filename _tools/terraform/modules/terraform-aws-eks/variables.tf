variable "eks_cluster_subnets" {
}
variable "eks_endpoint_public_access" {
  default = true
}
variable "eks_endpoint_private_access" {
  default = true
}
variable "eks_trusted_networks" {
  default = [
    "0.0.0.0/0"
  ]
}

variable "env" {
}

variable "region" {
  default = "eu-west-1"
}

variable "service" {
  default = "eks"
}

variable "role" {
  default = "cluster"
}

variable "eks_nodes_disk_size" {
  default = 20
}

variable "eks_nodes_instance_types" {
  default = [
  "t3.medium"]
}

variable "eks_node_pool_desired_size" {
  default = 1
}

variable "eks_node_pool_max_size" {
  default = 3
}

variable "eks_node_pool_min_size" {
  default = 1
}

variable "admin_role_arn" {}

variable "user_role_arn" {}

variable "datadog_metrics_enabled" {
  description = "Enable Datadog to fetch metrics from specific EC2"
  type        = bool
  default     = false
}

variable "eks_authorized_users" {
  type    = list(string)
  default = []
}

variable "eks_authorized_accounts" {
  type    = list(string)
  default = []
}

variable "eks_authorized_roles" {
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = [
  ]
}

variable "aws_cli_install" {
  default = false
}

variable "start_stop_enabled" {
  description = "Whether or not start / stop the eks cluster"
  default     = true
  type        = bool
}

# See: https://docs.aws.amazon.com/eks/latest/userguide/eks-linux-ami-versions.html
variable "eks_nodes_release_version" {
  description = "AMI version of the EKS Node Group. Defaults to latest version for Kubernetes version."
  default     = "1.16.15-20201211"
}