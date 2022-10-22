terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "fred-iac"

    workspaces {
      prefix = "vpc-"
    }
  }
  required_version = ">= 0.13.0"
}