variable "env" {
  default = "qa"
}

variable "org_prefix" {
  default = "fred-iac"
}

variable "region" {
  default = "eu-west-1"
}

variable "versioning" {
  default     = {}
  type        = map(string)
  description = "Define the block for default versioning_configuration of the bucket"
}

variable "lifecycle_rules" {
  description = "List of lifecycle rules"
  default     = []
  type        = any
}

variable "bucket_tags" {
  type        = map(string)
  default     = {}
  description = "A mapping of tags to assign to the bucket."
}

variable "bucket_prefix" {
  description = "Prefix for current bucket"
  default     = "logs"
}

# https://docs.aws.amazon.com/elasticloadbalancing/latest/classic/enable-access-logs.html
variable "elb_account_id" {
  description = "List of ID account for loadbalancer per region (region: account_id)"
  type        = map(string)
  default     = {}
}
