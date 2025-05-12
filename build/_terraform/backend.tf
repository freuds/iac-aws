terraform {
  backend "remote" {
    organization = "fred-iac"
  }
  required_version = ">= 1.0"
}
