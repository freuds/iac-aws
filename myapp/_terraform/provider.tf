terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.42.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.2.0"
    }
  }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Owner = "fred"
    }
  }
}
