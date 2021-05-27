variable "env" {}

variable "cloudcraft_account_id" {
  description = "Cloudcraft identity account ID"
  default     = ""
}

variable "cloudcraft_external_id" {
  description = "CloudCraft identity external ID"
  default     = ""
}

variable "tags" {
  description = "Map of tags to apply to resources"
  type        = map(string)
  default = {
    Service = "CloudCraft"
  }
}
