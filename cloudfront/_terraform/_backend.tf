terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "fred-iac"
  }
  required_version = ">= 0.12.25"
}