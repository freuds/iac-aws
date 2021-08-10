variable "env" {
  default = "qa"
}

variable "org_prefix" {
  default = "fred-iac"
}

variable "region" {
  default = "eu-west-1"
}

variable "org" {
  default = "fred-iac"
}

variable "versioning_enabled" {
  default     = false
  type        = string
  description = "Enable versioning. Versioning is a means of keeping multiple variants of an object in the same bucket."
}

variable "force_destroy" {
  default     = false
  type        = string
  description = "A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error."
}
variable "lifecycle_rule_enabled" {
  default     = true
  type        = string
  description = "Specifies lifecycle rule status."
}

variable "lifecycle_rule_prefix" {
  default     = ""
  type        = string
  description = "Object key prefix identifying one or more objects to which the rule applies."
}

variable "standard_ia_transition_days" {
  default     = "30"
  type        = string
  description = "Specifies a period in the object's STANDARD_IA transitions."
}

variable "glacier_transition_days" {
  default     = "60"
  type        = string
  description = "Specifies a period in the object's Glacier transitions."
}

variable "expiration_days" {
  default     = "90"
  type        = string
  description = "Specifies a period in the object's expire."
}

variable "glacier_noncurrent_version_transition_days" {
  default     = "30"
  type        = string
  description = "Specifies when noncurrent object versions transitions."
}

variable "noncurrent_version_expiration_days" {
  default     = "60"
  type        = string
  description = "Specifies when noncurrent object versions expire."
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

variable "log_filter_prefix" {
  default = ["logs/AWSLogs", "cloudfront"]
}

# https://docs.aws.amazon.com/elasticloadbalancing/latest/classic/enable-access-logs.html
variable "elb_account_id" {
  description = "List of ID account for loadbalancer per region"
  type        = map(string)
  default = {
    "eu-west-1" = "156460612806",
    "eu-west-2" = "652711504416",
    "eu-west-3" = "009996457667",
  }
}