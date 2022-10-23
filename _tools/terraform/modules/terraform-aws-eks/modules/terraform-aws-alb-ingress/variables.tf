variable "eks_cluster_name" {
  type = string
}

variable "k8s_namespace" {
  type    = string
  default = "default"
}

variable "k8s_pod_labels" {
  type    = map(string)
  default = {}
}

variable "k8s_pod_annotations" {
  type    = map(string)
  default = {}
}

variable "k8s_replicas" {
  type    = number
  default = 1
}

variable "service" {
  type    = string
  default = "alb"
}

variable "env" {
  type = string
}

variable "role" {
  type    = string
  default = "ingress-controller"
}

variable "aws_alb_ingress_controller_version" {
  type    = string
  default = "1.1.8"
}
