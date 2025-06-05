variable "org_prefix" {}

variable "iam_access_to_billing" {
  default = "DENY"
}

variable "env" {}

variable "region" {
  default = "eu-west-1"
}

variable "iam_admin_role_name" {
  default = "devops"
}

variable "service_access_principals" {
  type = list(string)
  default = [
    "cloudtrail.amazonaws.com"
  ]
}
variable "org_multi_region_trail" { default = true }

variable "accounts" {
  type = map(string)

  default = {
    "prod"    = "devops-prod@example.com"
    "staging" = "devops-staging@example.com"
    "qa"      = "devops-qa@example.com"
  }
}




