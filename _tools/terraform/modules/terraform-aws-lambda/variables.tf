variable "env" {
  default     = ""
  description = "Environment"
}

variable "lambda_name" {
  default     = ""
  description = "Name of lambda function"
}

variable "force_destroy" {
  default     = true
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

variable "xray_enable" {
  default = false
  type = bool
  description = "Enable or not the AWS X-Ray service for lambda"
}

variable "layer_type_lib" {
  default = "nodejs"
  type = string
  description = "Define the library used for the layer SDK"
}

variable "layer_description" {
  default = "Layer for X-Ray SDK"
  type = string
}

variable "license_info" {
  default = "MIT License"
  type = string
}

variable "compatible_runtimes" {
  default = {
    nodejs = [
      "nodejs12.x",
      "nodejs14.x"]
    python = [
      "python3.6",
      "python3.7",
      "python3.8"]
  }
  type = map(list(string))
  description = "Define the compatible library SDK"
}