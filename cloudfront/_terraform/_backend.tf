terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "phenix"
  }
  required_version = ">= 0.12.25"
}