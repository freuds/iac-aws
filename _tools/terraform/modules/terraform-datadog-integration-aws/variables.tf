variable "region" {
  default = "eu-west-1"
}

variable "datadog_policy_name" {
  description = "Datadog policy name"
  type        = string
  default     = "DatadogAWSIntegrationPolicy"
}

variable "trail_policy_read_only_name" {
  description = "trail policy RO name"
  type        = string
  default     = "DatadogAWSTrailPolicyRO"
}

variable "host_tags" {
  description = "Array of tags (in the form key:value) to add to all hosts and metrics"
  type        = list(string)
  default     = [
    "key:value",
    "key2:value2"
  ]
}

variable "aws_account_id" {
  description = "AWS account target"
  default     = "1234567890"
}

variable "datadog_policy_external_id" {
  description = "datadog external id from integration tile"
  default     = "1234567890"
}

variable "datadog_role_name" {
  description = "Datadog role name"
  type        = string
  default     = "DatadogAWSIntegrationRole"
}