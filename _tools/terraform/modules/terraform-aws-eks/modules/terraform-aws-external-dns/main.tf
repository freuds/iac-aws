data "aws_caller_identity" "current" {}

data "aws_eks_cluster" "current" {
  name = var.eks_cluster_name
}

data "aws_region" "current" {}

locals {
  k8s_resources_labels = merge({
    "born2scale.io/terraform-module" = "eks-external-dns",
  }, var.k8s_resources_labels)
}

resource "kubernetes_namespace" "external_dns" {
  count = var.k8s_namespace_create  && var.enabled ? 1 : 0
  metadata {
    name = var.k8s_namespace
  }
}

resource "kubernetes_service_account" "external_dns" {
  count = var.enabled ? 1 : 0
  metadata {
    name        = "${var.k8s_resources_name_prefix}external-dns"
    namespace   = var.k8s_namespace
    labels      = local.k8s_resources_labels
    annotations = {
      "eks.amazonaws.com/role-arn" = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${aws_iam_role.external_dns.0.name}"
    }
  }
  # BUG (see github): https://github.com/hashicorp/terraform-provider-kubernetes/issues/263
  automount_service_account_token = true
}

# IAM Role
resource "aws_iam_role" "external_dns" {
  count              = var.enabled ? 1 : 0
  name               = "external-dns"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.eks_oidc_assume_role.json
}

data "aws_iam_policy_document" "eks_oidc_assume_role" {
  statement {
    actions = [
      "sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    condition {
      test     = "StringEquals"
      variable = "${replace(data.aws_eks_cluster.current.identity[0].oidc[0].issuer, "https://", "")}:sub"
      values   = [
        "system:serviceaccount:${var.k8s_namespace}:${var.k8s_resources_name_prefix}external-dns"
      ]
    }
    principals {
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(data.aws_eks_cluster.current.identity[0].oidc[0].issuer, "https://", "")}"
      ]
      type        = "Federated"
    }
  }
}

#  IAM Role Policy
resource "aws_iam_role_policy" "r53_write_access" {
  count  = var.enabled ? 1 : 0
  name   = "external-dns-r53-write-access"
  role   = aws_iam_role.external_dns.0.id
  policy = data.aws_iam_policy_document.r53_write_access.json
}

data "aws_iam_policy_document" "r53_write_access" {
  statement {
    actions = [
      "route53:ChangeResourceRecordSets"
    ]

    resources = [
      "arn:aws:route53:::hostedzone/*"
    ]
  }

  statement {
    actions = [
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets"
    ]

    resources = [
      "*"
    ]
  }
}

resource "helm_release" "external_dns" {
  count      = var.enabled ? 1 : 0
  name       = "external-dns"
  repository = var.helm_chart_repo
  chart      = "external-dns"
  namespace  = var.k8s_namespace

  values = [
    file("values.yaml"),
  ]

  set {
    name  = "provider"
    value = var.external_dns_provider_name
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = kubernetes_service_account.external_dns.0.metadata.0.name
  }

  set {
    name  = "aws.region"
    value = data.aws_region.current.name
  }

  set {
    name  = "aws.aws.assumeRoleArn"
    value = aws_iam_role.external_dns.0.arn
  }

  set {
    name  = "aws.zoneType"
    value = var.r53_zone_type
  }

  set {
    name  = "rbac.create"
    value = true
  }

  set {
    name  = "sources[0]"
    value = "service"
  }

  set {
    name  = "sources[1]"
    value = "ingress"
  }
}

