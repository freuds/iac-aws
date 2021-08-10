variable "env" {
  default     = ""
  description = "Environment"
}

variable "lambda_name" {
  default     = ""
  description = "Name of lambda function"
}

variable "force_destroy" {
  default     = false
  type        = string
  description = "A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error."
}

variable "lambda_runtime" {
  default     = "nodejs12.x"
  type        = string
  description = "Engine Runtime for Lambda function"
}

variable "lambda_handler" {
  default     = "lambda-hello-world"
  type        = string
  description = "handler for Lambda function : .handler as suffix"
}