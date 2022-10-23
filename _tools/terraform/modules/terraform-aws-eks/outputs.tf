output "eks_cluster_arn" {
  value = aws_eks_cluster.default.arn
}

output "eks_cluster_name" {
  value = aws_eks_cluster.default.name
}

output "eks_node_iam_role_arn" {
  value = aws_eks_node_group.default.node_role_arn
}

output "eks_cluster_api_endpoint" {
  value = aws_eks_cluster.default.endpoint
}

output "eks_cluster_default_node_group_asg" {
  value = local.eks_asg_name
}

output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster OIDC Issuer"
  value       = aws_iam_openid_connect_provider.eks.url
}

output "eks_cluster_id" {
  value = aws_eks_cluster.default.id
}

output "eks_cluster_sg_id" {
  value = aws_eks_cluster.default.vpc_config[0].cluster_security_group_id
}