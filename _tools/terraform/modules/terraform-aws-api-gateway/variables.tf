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
  description = ""
}

variable "function_name" {
  default     = ""
  type        = string
  description = "Function name for Api Gateway"
}

variable "subnet_ids" {
  default     = []
  type        = list
  description = "List of subnet IDs"
}

variable "security_group_ids" {
  default     = []
  type        = list
  description = "List of subnet IDs"
}
