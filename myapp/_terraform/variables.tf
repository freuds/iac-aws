variable "env" {
  type        = string
  default     = ""
  description = "Environment"
}

variable "organization" {
  default = "fred-iac"
}

variable "service" {
  type        = string
  default     = "myapp"
  description = "Service Name"
}

variable "region" {
  type        = string
  default     = "eu-west-1"
  description = "Region selected"
}

variable "lambda_name" {
  type        = string
  default     = "hello-world"
  description = "Name of lambda function"
}

variable "lambda_runtime" {
  default     = "nodejs12.x"
  type        = string
  description = "Engine Runtime for Lambda function"
}

variable "lambda_handler" {
  default     = "index"
  type        = string
  description = "handler for Lambda function : .handler as suffix"
}

variable "function_name" {
  default     = ""
  type        = string
  description = "Function name for Api Gateway"
}

variable "xray_enable" {
  default     = true
  type        = bool
  description = "Enable or not the AWS X-Ray service for lambda"
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
  type        = map(list(string))
  description = "Define the compatible library SDK"
}
