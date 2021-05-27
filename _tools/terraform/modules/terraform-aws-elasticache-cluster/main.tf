resource "random_id" "elasticache" {
  byte_length = 2
}

// Redis Cluster Mode Disabled
resource "aws_elasticache_replication_group" "elasticache" {
  count                         = var.redis_enable ? 1 : 0
  replication_group_id          = format("%s-%s-%s-%s-%s", var.env, var.service, var.role, var.engine, random_id.elasticache.hex)
  replication_group_description = "Redis cluster for ElastiCache"

  engine_version       = var.engine_version
  engine               = var.engine
  node_type            = var.node_type
  port                 = var.port
  parameter_group_name = var.parameter_group_name
  apply_immediately    = var.apply_immediately
  maintenance_window   = var.maintenance_window

  snapshot_retention_limit = var.snapshot_retention_limit
  snapshot_window          = var.snapshot_window

  automatic_failover_enabled = var.automatic_failover_enabled

  number_cache_clusters = var.number_cache_clusters
  subnet_group_name     = var.subnet_group_name

  security_group_ids = [
    aws_security_group.sgp-elasticache.id
  ]

  tags = {
    env         = var.env
    environment = var.env
    service     = var.service
    role        = var.role
    name        = format("%s-%s-%s-%s-%s", var.env, var.service, var.role, var.engine, random_id.elasticache.hex)
  }

  lifecycle {
    ignore_changes = [number_cache_clusters]

    create_before_destroy = true
  }

}

# hack for activate multi-az option:
# see: https://github.com/hashicorp/terraform-provider-aws/issues/13706
resource "null_resource" "nr" {
  count = var.env != "qa" ? 1 : 0
  triggers = {
    cache = aws_elasticache_replication_group.elasticache[0].id
  }
  provisioner "local-exec" {
    command = "aws elasticache modify-replication-group --replication-group-id ${aws_elasticache_replication_group.elasticache[0].id} --multi-az-enabled --apply-immediately"
  }
  depends_on = [
    aws_elasticache_replication_group.elasticache
  ]
}

resource "aws_elasticache_cluster" "elasticache" {
  count                = var.number_elasticache_replica
  cluster_id           = format("%s-%s-%s-%s-%s-%s", var.env, var.service, var.role, var.engine, random_id.elasticache.hex, count.index)
  replication_group_id = aws_elasticache_replication_group.elasticache[0].id
}

resource "aws_security_group" "sgp-elasticache" {

  name        = "sgp-${var.env}-${var.service}-${var.role}-${var.engine}"
  description = "security group for ${var.env} ${var.service} ${var.role} ${var.engine}"
  vpc_id      = var.vpc_id
  tags = {
    name        = "sgp-${var.env}-${var.service}-${var.role}-${var.engine}"
    service     = var.service
    role        = var.role
    env         = var.env
    environment = var.env
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "private_dns_elasticache" {
  count   = var.redis_enable ? 1 : 0
  zone_id = var.aws_route53_zone_private_id
  name    = "${var.service}-${var.role}-${var.engine}"
  type    = "CNAME"
  ttl     = var.r53_prv_ttl
  records = [
    aws_elasticache_replication_group.elasticache[0].primary_endpoint_address
  ]
}
