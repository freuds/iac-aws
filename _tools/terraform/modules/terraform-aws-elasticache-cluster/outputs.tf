output "redis_group_id" {
  value = aws_elasticache_replication_group.elasticache[0].id
}
output "redis_config_endpoint_address" {
  value = aws_elasticache_replication_group.elasticache[0].configuration_endpoint_address
}
output "redis_primary_endpoint_address" {
  value = aws_elasticache_replication_group.elasticache[0].primary_endpoint_address
}

output "redis_sgp_id" {
  value = aws_security_group.sgp-elasticache.id
}