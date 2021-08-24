variable "env" {
  default     = ""
  type        = string
  description = "Environment"
}

variable "service" {
  default = ""
  type    = string
}

variable "protocol_type" {
  default     = "HTTP"
  type        = string
  description = "Protocol Type"
}

variable "integration_uri" {
  default     = ""
  type        = string
  description = "The URI of the Lambda function for a Lambda proxy integration, when integration_type is AWS_PROXY. For an HTTP integration, specify a fully-qualified URL. For an HTTP API private integration, specify the ARN of an Application Load Balancer listener, Network Load Balancer listener, or AWS Cloud Map service"
}

variable "function_name" {
  default     = ""
  type        = string
  description = "Function name for Api Gateway"
}

variable "subnet_ids" {
  default     = []
  type        = list(any)
  description = "List of subnet IDs"
}

variable "security_group_ids" {
  default     = []
  type        = list(any)
  description = "List of subnet IDs"
}

variable "certificat_arn" {
  default     = ""
  type        = string
  description = "arn certificate"
}

variable "public_domain" {
  default     = ""
  type        = string
  description = "Public domain name"
}

variable "public_host_zone_id" {
  default     = ""
  type        = string
  description = "Public zone ID"
}

variable "auto_deploy" {
  default     = true
  type        = string
  description = "Whether updates to an API automatically trigger a new deployment. Defaults to false. Applicable for HTTP APIs"
}

variable "detailed_metrics_enabled" {
  default     = false
  type        = bool
  description = "Whether detailed metrics are enabled for the default route"
}

variable "logging_level" {
  default     = "OFF"
  type        = string
  description = "The logging level for the default route. Affects the log entries pushed to Amazon CloudWatch Logs. Valid values: ERROR, INFO, OFF"
}

variable "api_description" {
  default     = "API Gateway"
  type        = string
  description = "The description of API Gateway resource"
}

variable "disable_execute_api_endpoint" {
  default     = true
  type        = bool
  description = "Whether clients can invoke the API by using the default execute-api endpoint"
}
