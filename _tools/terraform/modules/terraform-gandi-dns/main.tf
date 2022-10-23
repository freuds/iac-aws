terraform {
  required_providers {
    gandi = {
      version = "2.0.0-rc3"
      source  = "psychopenguin/gandi"
    }
  }
}

provider "gandi" {
  key = var.gandi_apikey
}

data "gandi_domain" "origin" {
  name = var.gandi_domain_name
}

resource "gandi_livedns_record" "aws-ns" {
  zone   = data.gandi_domain.origin.id
  name   = var.gandi_alias_ns
  type   = "NS"
  ttl    = var.ns_ttl
  values = var.gandi_aws_ns

  lifecycle {
    create_before_destroy = true
  }
}
