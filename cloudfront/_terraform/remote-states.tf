data "terraform_remote_state" "baseline" {
  backend = "remote"
  config = {
    organization = var.organization
    workspaces = {
      name = "baseline-${var.env}-${var.region}"
    }
  }
}

data "terraform_remote_state" "vpc" {
  backend = "remote"
  config = {
    organization = var.organization
    workspaces = {
      name = "vpc-${var.env}-${var.region}"
    }
  }
}

// data "terraform_remote_state" "varnish" {
//   backend = "remote"
//   config = {
//     organization = var.organization
//     workspaces = {
//       name = "varnish-${var.env}-${var.region}"
//     }
//   }
// }