// Create 'n' number of DB instance(s) in same cluster
resource "aws_rds_cluster_instance" "cluster_instance_n" {
  count                        = var.replica_count
  apply_immediately            = var.apply_immediately
  engine                       = var.engine
  engine_version               = var.engine-version
  identifier                   = format("%s-%s-%s-%s-%d", var.env, var.service, var.role, var.engine, count.index)
  cluster_identifier           = aws_rds_cluster.default[0].id
  instance_class               = var.instance_type
  publicly_accessible          = var.publicly_accessible
  db_subnet_group_name         = var.db_subnet_group_name
  preferred_maintenance_window = var.preferred_maintenance_window
  auto_minor_version_upgrade   = var.auto_minor_version_upgrade
  promotion_tier               = count.index
  tags = {
    env         = var.env
    environment = var.env
    service     = var.service
    role        = var.role
    name        = format("%s-%s-%s-%s-%d", var.env, var.service, var.role, var.engine, count.index)
  }
}

// Create DB Cluster}
resource "aws_rds_cluster" "default" {
  depends_on = [
    aws_rds_cluster_parameter_group.default,
    aws_kms_key.aurora-kms-key
  ]
  count                           = var.cluster_enable ? 1 : 0
  cluster_identifier              = "${var.env}-${var.service}-${var.role}"
  availability_zones              = var.azs[var.region]
  engine                          = var.engine
  engine_version                  = var.engine-version
  database_name                   = var.db_name
  master_username                 = var.username
  master_password                 = var.password
  backup_retention_period         = var.backup_retention_period
  preferred_backup_window         = var.preferred_backup_window
  preferred_maintenance_window    = var.preferred_maintenance_window
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.default.name
  port                            = var.port
  db_subnet_group_name            = var.db_subnet_group_name
  vpc_security_group_ids = [
  aws_security_group.sgp-aurora.id]
  storage_encrypted               = var.storage_encrypted
  kms_key_id                      = var.storage_encrypted == "true" ? aws_kms_key.aurora-kms-key.arn : ""
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  apply_immediately               = var.apply_immediately
  tags = {
    name           = "${var.env}-${var.service}-${var.role}"
    service        = var.service
    env            = var.env
    environment    = var.env
    role           = var.role
    engine-version = var.engine-version
    engine         = var.engine
    stop           = var.start_stop_enabled
  }
}

resource "aws_kms_key" "aurora-kms-key" {
  description             = "kms key for aurora"
  deletion_window_in_days = 10
  tags = {
    name    = "kms-${var.env}-${var.service}-${var.role}-${var.engine}"
    service = var.service
    env     = var.env
    role    = var.role
  }
}

resource "aws_security_group" "sgp-aurora" {
  name        = "sgp-${var.env}-${var.service}-${var.role}-${var.engine}"
  description = "security group for ${var.env} ${var.service} ${var.role} ${var.engine}"
  vpc_id      = var.vpc_id
  tags = {
    name    = "sgp-${var.env}-${var.service}-${var.role}-${var.engine}"
    service = var.service
    role    = var.role
    env     = var.env
  }
}

resource "aws_rds_cluster_parameter_group" "default" {
  name        = "${var.env}-${var.service}-${var.role}-${var.engine}-pg"
  family      = var.family
  description = "RDS cluster parameter group for ${var.env}-${var.service}-${var.role}"
  dynamic "parameter" {
    for_each = var.parameters-pg
    content {
      name         = parameter.value["name"]
      value        = parameter.value["value"]
      apply_method = parameter.value["apply_method"]
    }
  }
}

resource "aws_route53_record" "private_dns_aurora" {
  count   = var.cluster_enable ? 1 : 0
  zone_id = var.aws_route53_zone_private_id
  name    = "${var.service}-db"
  type    = "CNAME"
  ttl     = var.r53_prv_ttl
  records = [
  aws_rds_cluster.default.0.endpoint]
}

resource "aws_route53_record" "private_dns_aurora_reader" {
  count   = var.cluster_reader_enable == "true" ? 1 : 0
  zone_id = var.aws_route53_zone_private_id
  name    = "${var.service}-db-reader"
  type    = "CNAME"
  ttl     = var.r53_prv_ttl
  records = [
  aws_rds_cluster.default.0.reader_endpoint]
}
