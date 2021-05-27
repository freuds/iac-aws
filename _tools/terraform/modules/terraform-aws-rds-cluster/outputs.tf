// The 'writer' endpoint for the cluster
output "cluster_endpoint" {
  value = aws_rds_cluster.default.0.endpoint
}

// List of all DB instance endpoints running in cluster
output "all_instance_endpoints_list" {
  value = [
    aws_rds_cluster_instance.cluster_instance_n.*.endpoint
  ]
}

// A read-only endpoint for the Aurora cluster, automatically load-balanced across replicas
output "reader_endpoint" {
  value = aws_rds_cluster.default.0.reader_endpoint
}

// The ID of the RDS Cluster
output "cluster_identifier" {
  value = aws_rds_cluster.default.0.id
}

output "aurora_sgp_id" {
  value = aws_security_group.sgp-aurora.id
}