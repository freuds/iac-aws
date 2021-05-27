variable "env" {
  type        = string
  description = "Environment name (eg,test, stage or prod)"
}

variable "service" {
  type        = string
  default     = "elasticache"
  description = "service name (eg bastion, aurora ...)"
}

variable "role" {
  type        = string
  default     = "cache"
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

variable "vpc_id" {
  default = ""
}

variable "cluster_id" {
  description = "Cluster ID you want to use"
}

variable "redis_enable" {
  default     = true
  description = "Whether the redis cluster resources should be created"
}

variable "engine_version" {
  description = "Redis engine version you want to use"
  default     = "5.0.6"
}

variable "node_type" {
  description = "Node type you want to use"
  default     = "cache.t3.micro"
}

variable "engine" {
  description = "Node type you want to use"
  default     = "redis"
}

variable "number_cache_clusters" {
  description = "The number of cache clusters (primary and replicas) this replication group will have. If Multi-AZ is enabled, the value of this parameter must be at least 2. Updates will occur before other modifications."
  default     = 2
}

variable "parameter_group_name" {
  description = "Name of the parameter group to associate with this cache cluster"
  default     = "default.redis5.0"
}

variable "port" {
  description = "The port number on which each of the cache nodes will accept connections"
  default     = "6379"
}

variable "maintenance_window" {
  description = "Specifies the weekly time range for when maintenance on the cache cluster is performed"
  default     = "sun:01:00-sun:03:00"
}

variable "subnet_group_name" {
  description = "Name of the subnet group to be used for the cache cluster"
}

variable "r53_prv_ttl" {
  default = 60
}

variable "aws_route53_zone_private_id" {
  default = ""
}

variable "apply_immediately" {
  default = false
}

variable "snapshot_window" {
  description = "The daily time range (in UTC) during which ElastiCache will begin taking a daily snapshot of your cache cluster. The minimum snapshot window is a 60 minute period."
  default = "03:00-05:00"
}

variable "snapshot_retention_limit" {
  description = "Max limit retention for Elasticache"
  default     = 5
}

variable "automatic_failover_enabled" {
  description = "Specifies whether a read-only replica will be automatically promoted to read/write primary if the existing primary fails. If true, Multi-AZ is enabled for this replication group. If false, Multi-AZ is disabled for this replication group."
  default     = true
}

variable "number_elasticache_replica" {
  description = "Number of Elasticache Replica: x number_elasticache_replica + number_cache_clusters = total nodes "
  default     = 0
}