variable "env" {
  type        = string
  description = "Environment name (eg,test, stage or prod)"
}

variable "service" {
  type        = string
  default     = "aurora"
  description = "service name (eg bastion, aurora ...)"
}

variable "role" {
  type        = string
  default     = "db"
  description = "role name (eg server, db ...)"
}

variable "azs" {
  type = map(list(string))
  default = {
    "eu-west-1" = [
      "eu-west-1a",
      "eu-west-1b",
      "eu-west-1c",
    ]
  }
}

variable "region" {
  default = "eu-west-1"
}

variable "replica_count" {
  type        = string
  default     = "1"
  description = "Number of nodes to create."
}

variable "instance_type" {
  type        = string
  default     = "db.t2.small"
  description = "Instance type to use"
}

variable "publicly_accessible" {
  type        = string
  default     = "false"
  description = "Whether the DB should have a public IP address"
}

variable "username" {
  type        = string
  default     = "admin"
  description = "Master DB username"
}

variable "password" {
  type        = string
  description = "Master DB password"
}

variable "backup_retention_period" {
  type        = string
  default     = "7"
  description = "How long to keep backups for (in days)"
}

variable "preferred_backup_window" {
  type        = string
  default     = "02:00-03:00"
  description = "When to perform DB backups"
}

variable "preferred_maintenance_window" {
  type        = string
  default     = "sun:05:00-sun:06:00"
  description = "When to perform DB maintenance"
}

variable "port" {
  type        = string
  default     = "3306"
  description = "The port on which to accept connections"
}

variable "auto_minor_version_upgrade" {
  type        = string
  default     = "true"
  description = "Determines whether minor engine upgrades will be performed automatically in the maintenance window"
}

variable "storage_encrypted" {
  type        = string
  default     = "true"
  description = "Specifies whether the underlying storage layer should be encrypted"
}

variable "engine" {
  type        = string
  default     = "aurora-mysql"
  description = "Aurora database engine type, currently aurora, aurora-mysql or aurora-postgresql"
}

variable "engine-version" {
  type        = string
  default     = "5.7.mysql_aurora.2.03.2"
  description = "Aurora database engine version."
}

variable "cluster_enable" {
  type        = string
  default     = true
  description = "Whether the database cluster resources should be created"
}

variable "cluster_reader_enable" {
  type        = string
  default     = false
  description = "enable router to reader endpoint"
}

variable "multi_instance" {
  type        = string
  default     = false
  description = "Flag for multi instance on the cluster"
}

variable "enabled_cloudwatch_logs_exports" {
  type        = list(string)
  default     = []
  description = "List of log types to export to CloudWatch Logs. If omitted, no logs will be exported. The following log types are supported: audit, error, general, slowquery, postgresql."
}

variable "db_subnet_group_name" {
  type        = string
  default     = "default-db-subnet-group-name"
  description = "subnet group name from VPC for Aurora"
}

variable "db_name" {
  type        = string
  default     = "auroraDB"
  description = "Aurora DB Name"
}

variable "vpc_id" {
  type        = string
  default     = "vpc-id"
  description = "vpc id"
}

variable "family" {
  type        = string
  default     = "aurora-mysql5.7"
  description = "DB cluster parameter group family name (eg aurora, aurora-mysql5.7 ...)"
}

variable "parameters-pg" {
  type = list(map(any))
  default = [
    {
      name         = "character_set_server"
      value        = "utf8"
      apply_method = "immediate"
    }
  ]
  description = "list of parameters for db config"
}

variable "aws_route53_zone_private_id" {
  default = ""
}

variable "r53_prv_ttl" {
  default = 60
}

variable "start_stop_enabled" {
  description = "Whether or not to start / stop instance daily"
  default     = true
  type        = bool
}


variable "apply_immediately" {
  default = false
}

