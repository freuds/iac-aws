variable "create" {
  description = "Controls whether the forwarder resources should be created"
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to use on all resources"
  type        = map(string)
  default     = {}
}

# Datadog environment Variables
variable "dd_api_key" {
  description = "The Datadog API key, which can be found from the APIs page (/account/settings#api). It will be stored in AWS Secrets Manager securely"
  type        = string
  default     = ""
}

variable "dd_site" {
  description = "Define your Datadog Site to send data to. For the Datadog EU site, set to datadoghq.eu"
  type        = string
  default     = "datadoghq.com"
}

variable "bucket_name" {
  description = "Forwarder S3 bucket name"
  type        = string
  default     = ""
}

# Forwarder S3 Zip Objcet
variable "bucket_prefix" {
  description = "S3 object key prefix to prepend to zip archive name"
  type        = string
  default     = ""
}

variable "s3_zip_storage_class" {
  description = "Specifies the desired Storage Class for the zip object. Can be either `STANDARD`, `REDUCED_REDUNDANCY`, `ONEZONE_IA`, `INTELLIGENT_TIERING`, or `STANDARD_IA`"
  type        = string
  default     = null
}

variable "s3_zip_server_side_encryption" {
  description = "Server-side encryption of the zip object in S3. Valid values are `AES256` and `aws:kms`"
  type        = string
  default     = null
}

variable "s3_zip_metadata" {
  description = "A map of keys/values to provision metadata (will be automatically prefixed by `x-amz-meta-`"
  type        = map(string)
  default     = {}
}

variable "s3_zip_tags" {
  description = "A map of tags to apply to the zip archive in S3"
  type        = map(string)
  default     = {}
}

variable "role_name" {
  description = "Forwarder role name"
  type        = string
  default     = ""
}

variable "role_max_session_duration" {
  description = "The maximum session duration (in seconds) that you want to set for the specified role. If you do not specify a value for this setting, the default maximum of one hour is applied. This setting can have a value from 1 hour to 12 hours."
  type        = number
  default     = null
}

variable "role_permissions_boundary" {
  description = "The ARN of the policy that is used to set the permissions boundary for the forwarder role."
  type        = string
  default     = null
}

variable "role_tags" {
  description = "A map of tags to apply to the forwarder role"
  type        = map(string)
  default     = {}
}

variable "policy_name" {
  description = "Forwarder policy name"
  type        = string
  default     = ""
}

variable "s3_log_bucket_arn" {
  description = "S3 log bucket for forwarder to read and forward logs to Datadog"
  type        = string
  default     = ""
}

variable "s3_log_bucket_id" {
  description = "S3 log bucket name for forwarder to read and forward logs to Datadog"
  type        = string
  default     = ""
}

variable "read_cloudwatch_logs" {
  description = "Whether the forwarder will read logs from CloudWatch or not"
  type        = bool
  default     = false
}

# Forwarder Lambda Function
variable "forwarder_version" {
  description = "Forwarder version - see https://github.com/DataDog/datadog-serverless-functions/releases"
  type        = string
  default     = "3.26.0"
}

variable "name" {
  description = "Forwarder lambda name"
  type        = string
  default     = "datadog-log-forwarder"
}

variable "runtime" {
  description = "Lambda function runtime"
  type        = string
  default     = "python3.7"
}

variable "layers" {
  description = "List of Lambda Layer Version ARNs (maximum of 5) to attach to the forwarder lambda"
  type        = list(string)
  default     = []
}

variable "memory_size" {
  description = "Memory size for the forwarder lambda function"
  type        = number
  default     = 1024
}

variable "timeout" {
  description = "The amount of time the forwarder lambda has to execute in seconds"
  type        = number
  default     = 120
}

variable "publish" {
  description = "Whether to publish creation/change as a new Lambda Function Version"
  type        = bool
  default     = false
}

variable "reserved_concurrent_executions" {
  description = "The amount of reserved concurrent executions for the forwarder lambda function"
  type        = number
  default     = 100
}

variable "environment_variables" {
  description = "A map of environment variables for the forwarder lambda function"
  type        = map(string)
  default     = {}
}

variable "lambda_tags" {
  description = "A map of tags to apply to the forwarder lambda function"
  type        = map(string)
  default     = {}
}

variable "log_retention_days" {
  description = "Forwarder CloudWatch log group retention in days"
  type        = number
  default     = 7
}
