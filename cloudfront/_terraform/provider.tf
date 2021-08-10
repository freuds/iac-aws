terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.42.0"
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

provider "aws" {
  alias  = "aws-global"
  region = "us-east-1"
}