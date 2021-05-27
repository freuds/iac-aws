terraform {
  backend "remote" {
    organization = "fred-iac-test"
  }
  required_version = ">= 0.13.0"
}