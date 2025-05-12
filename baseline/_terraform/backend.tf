terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "fred-iac"

    workspaces {
      prefix = "baseline-"
    }
  }
}
