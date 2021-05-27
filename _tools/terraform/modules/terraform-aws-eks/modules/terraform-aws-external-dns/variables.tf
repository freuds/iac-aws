variable "k8s_namespace_create" {
  type        = bool
  default     = false
  description = "Whether or not a specific namespace should be created for external dns"
}

variable "k8s_namespace" {
  default = "kube-system"
}

variable "eks_cluster_name" {
  type = string
}

variable "enabled" {
  type        = bool
  default     = true
  description = "Feature flag to enable / disable all module ressources"
}

variable "k8s_resources_name_prefix" {
  type    = string
  default = ""
}

variable "k8s_resources_labels" {
  type    = map(string)
  default = {}
}

variable "external_dns_provider_name" {
  type        = string
  default     = "aws"
  description = "The external-dns provider to user for ingress DNS sync"
}

variable "r53_zone_type" {
  type    = string
  default = "private"
}

variable "helm_chart_repo" {
  type    = string
  default = "https://charts.bitnami.com/bitnami"
}