# ALB Ingress Controller

This folder contains a Terraform module to deploy an ALB Ingress Controller in AWS on top of EKS Cluster.

## How to use this module

This folder defines a Terraform module, which you can use in your code by adding a module configuration and setting its `source` parameter to URL of this folder.

```hcl
module "alb_ingress_controller" {
  source           = "git@github.com:example/terraform-aws-eks.git/modules/terraform-aws-alb-ingress"
  k8s_namespace    = "kube-system"
  env              = var.env
  providers        = {
    kubernetes = "kubernetes.eks"
  }
  eks_cluster_name = module.eks.eks_cluster_name
}
```