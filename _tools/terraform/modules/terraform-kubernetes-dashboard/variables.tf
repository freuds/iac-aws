variable "enabled" {
  type        = bool
  default     = true
  description = "Flag that indicates whether the Kubernetes Dashboard should be enabled or not"
}

variable "k8s_namespace" {
  type        = string
  default     = "kubernetes-dashboard"
  description = "Kubernetes namespace to deploy kubernetes dashboard controller."
}

variable "k8s_namespace_create" {
  type        = bool
  default     = true
  description = "Do you want to create kubernetes namespace?"
}

variable "k8s_resources_name_prefix" {
  type        = string
  default     = ""
  description = "Prefix for kubernetes resources name. For example `tf-module-`"
}

variable "k8s_resources_labels" {
  type        = map(string)
  default     = {}
  description = "Additional labels for kubernetes resources."
}

variable "k8s_deployment_image_registry" {
  type    = string
  default = "kubernetesui/dashboard"
}

variable "k8s_deployment_image_tag" {
  type    = string
  default = "v2.0.0"
}

variable "k8s_deployment_metrics_scraper_image_registry" {
  type    = string
  default = "kubernetesui/metrics-scraper"
}

variable "k8s_deployment_metrics_scraper_image_tag" {
  type    = string
  default = "latest"
}

variable "k8s_deployment_node_selector" {
  type = map(string)
  default = {
    "kubernetes.io/os" = "linux"
  }
  description = "Node selectors for kubernetes deployment"
}

variable "k8s_deployment_tolerations" {
  type = list(object({
    key      = string
    operator = string
    value    = string
    effect   = string
  }))

  default = [
    {
      key      = "node-role.kubernetes.io/master"
      operator = "Equal"
      value    = ""
      effect   = "NoSchedule"
    }
  ]
}

variable "k8s_service_account_name" {
  type        = string
  default     = "kubernetes-dashboard"
  description = "Kubernetes service account name."
}

variable "k8s_secret_certs_name" {
  type        = string
  default     = "kubernetes-dashboard-certs"
  description = "Kubernetes secret certs name."
}

variable "k8s_role_name" {
  type        = string
  default     = "kubernetes-dashboard"
  description = "Kubernetes role name."
}

variable "k8s_role_binding_name" {
  type        = string
  default     = "kubernetes-dashboard"
  description = "Kubernetes role binding name."
}

variable "k8s_deployment_name" {
  type        = string
  default     = "kubernetes-dashboard"
  description = "Kubernetes deployment name."
}

variable "k8s_service_name" {
  type        = string
  default     = "kubernetes-dashboard"
  description = "Kubernetes service name."
}

variable "k8s_ingress_name" {
  type        = string
  default     = "kubernetes-dashboard"
  description = "Kubernetes ingress name."
}

variable "k8s_dashboard_csrf" {
  type        = string
  description = "CSRF token"
  default     = "A3JAMbydWxcNZEis9xF6Ggdf"
}