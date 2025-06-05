terraform {
  required_providers {
    gandi = {
      source  = "go-gandi/gandi"
      version = "2.3.0"
    }
  }
}

provider "gandi" {
  personal_access_token = var.gandi_personal_access_token
}

data "gandi_domain" "origin" {
  name = var.gandi_domain_name
}

resource "gandi_livedns_record" "record" {
  zone   = data.gandi_domain.origin.id
  name   = var.gandi_alias_ns
  type   = "NS"
  ttl    = var.ns_ttl
  values = var.gandi_aws_ns

  lifecycle {
    create_before_destroy = true
  }
}
