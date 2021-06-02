provider "aws" {
  region  = var.region
  version = "~> 2.0"
}

provider "aws" {
  alias   = "aws-global"
  region  = "us-east-1"
  version = "~> 2.0"
}