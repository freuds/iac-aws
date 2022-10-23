module "eks" {
  source                      = "git@github.com:born2scale/terraform-aws-eks.git"
  providers                   = {
    kubernetes = kubernetes.eks
  }
  env                         = var.env
  region                      = var.region
  aws_cli_install             = var.tf_cloud_awscli_install
  eks_cluster_subnets         = data.terraform_remote_state.vpc.outputs.private_subnets
  eks_node_pool_desired_size  = var.eks_node_pool_desired_size
  eks_trusted_networks        = var.eks_trusted_networks
  eks_endpoint_public_access  = var.eks_endpoint_public_access
  eks_endpoint_private_access = var.eks_endpoint_private_access
  eks_nodes_disk_size         = var.eks_nodes_disk_size
  eks_nodes_instance_types    = var.eks_nodes_instance_types
  eks_node_pool_max_size      = var.eks_node_pool_max_size
  eks_node_pool_min_size      = var.eks_node_pool_min_size
  admin_role_arn              = data.terraform_remote_state.baseline.outputs.admin_role_arn
  user_role_arn               = data.terraform_remote_state.baseline.outputs.user_role_arn
  start_stop_enabled          = var.start_stop_enabled
  datadog_metrics_enabled     = var.datadog_metrics_enabled
  eks_nodes_release_version   = var.eks_nodes_release_version
}

data "aws_eks_cluster" "current" {
  name = module.eks.eks_cluster_name
}

data "aws_eks_cluster_auth" "aws_iam_authenticator" {
  name = data.aws_eks_cluster.current.name
}

module "alb_ingress_controller" {
  source           = "git@github.com:born2scale/terraform-aws-eks.git/modules/terraform-aws-alb-ingress"
  providers        = {
    kubernetes = kubernetes.eks
  }
  env              = var.env
  eks_cluster_name = module.eks.eks_cluster_name

}

module "external_dns" {
  source           = "git@github.com:born2scale/terraform-aws-eks.git/modules/terraform-aws-external-dns"
  providers        = {
    kubernetes = kubernetes.eks
    helm       = helm.eks
  }
  eks_cluster_name = module.eks.eks_cluster_name
}

module "k8s_dashboard" {
  source    = "git@github.com:born2scale/terraform-aws-eks.git/modules/terraform-aws-alb-ingress"
  providers = {
    kubernetes = kubernetes.eks
  }
  enabled   = var.dashboard_enabled
}

locals {
  k8s_service_account_namespace = "kube-system"
  k8s_service_account_name      = "cluster-autoscaler-aws-cluster-autoscaler"
}

data "aws_caller_identity" "current" {}
