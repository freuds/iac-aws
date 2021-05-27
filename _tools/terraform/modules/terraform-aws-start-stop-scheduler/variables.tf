variable "env" {
  description = "The environment in which this lamdda scheduler will be runing"
  type        = string
  default     = ""
}

variable "schedule_action" {
  description = "Define schedule action to apply on resources, accepted value are 'stop or 'start"
  type        = string
  default     = "stop"
}

variable "resources_tag" {
  description = "Set the tag use to identify resources to stop or start"
  type        = map(string)

  default = {
    key   = "start-stop"
    value = "true"
  }
}

variable "autoscaling_schedule" {
  description = "Enable scheduling on autoscaling resources"
  type        = string
  default     = "false"
}

variable "rds_schedule" {
  description = "Enable scheduling on rds resources"
  type        = string
  default     = "false"
}

variable "cloudwatch_schedule_expression" {
  description = "Define the aws cloudwatch event rule schedule expression"
  type        = string
  default     = "cron(0 22 ? * MON-FRI *)"
}

variable "name" {
  description = "Name of the lambda scheduler (must be unique to avoid collision)"
  default = "start-stop"
  type = string
}