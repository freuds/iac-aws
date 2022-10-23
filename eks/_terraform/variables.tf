variable "organization" {
  default = "phenix"
}

variable "env" {}

variable "region" {
  default = "eu-west-1"
}

variable "tf_cloud_awscli_install" {
  default = false
}

variable "eks_node_pool_desired_size" {
  default = 1
}
variable "eks_trusted_networks" {
  default = [
    "0.0.0.0/0"
  ]
}
variable "eks_endpoint_public_access" {
  default = true
}
variable "eks_endpoint_private_access" {
  default = true
}
variable "eks_nodes_disk_size" {
  default = 20
}
variable "eks_nodes_instance_types" {
  default = [
    "t3.large"]
}
variable "eks_node_pool_max_size" {
  default = 3
}
variable "eks_node_pool_min_size" {
  default = 1
}
variable "start_stop_enabled" {
  description = "Whether or not to start / stop haproxy daily"
  default     = true
  type        = bool
}

variable "datadog_metrics_enabled" {
  default = false
}

variable "dashboard_enabled" {
  default = true
}

variable "eks_nodes_release_version" {
  description = "AMI version of the EKS Node Group. Defaults to latest version for Kubernetes version."
  default     = "1.16.15-20201211"
}