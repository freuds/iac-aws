variable "gandi_api_key" {
  default     = ""
  type        = string
  description = "Gandi API Key"
}

variable "ns_ttl" {
  default = 3600
  type    = number
}

variable "gandi_domain_name" {
  default     = "domain.com"
  type        = string
  description = "Domain Name"
}

variable "gandi_aws_ns" {
  default     = []
  type        = list(string)
  description = "AWS API Route53 for delegation domain"
}

variable "gandi_alias_ns" {
  default = ""
  type = string
  description = "Alias Name for NS records"
}