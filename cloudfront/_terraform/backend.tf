terraform {
  backend "remote" {
    organization = "fred-iac"
  }
  required_version = ">= 0.13.0"
}