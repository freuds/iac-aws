terraform {
  backend "remote" {
    organization = "phenix"
  }
  required_version = ">= 0.13.0"
}