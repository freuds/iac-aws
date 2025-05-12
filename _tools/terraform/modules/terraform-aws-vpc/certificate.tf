# locals {
#   external_domain_name = var.env == "prod" ? replace(var.external_domain_name, var.env, "") : var.external_domain_name
# }

resource "aws_acm_certificate" "cert" {
  domain_name = var.external_domain_name
  subject_alternative_names = [
    "*.${var.external_domain_name}"
  ]
  validation_method = "DNS"

  tags = {
    Environment = var.env
  }

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_route53_zone" "cert" {
  name         = var.external_domain_name
  private_zone = false

  # depends on route53 zone public
  depends_on = [
    aws_route53_zone.public
  ]
}

resource "aws_route53_record" "cert" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.cert.zone_id
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert : record.fqdn]
}

// data "aws_acm_certificate" "prod" {
//   count       = var.env == "prod" ? 1 : 0
//   domain      = replace(var.external_domain_name, "${var.env}.", "")
//   most_recent = true
// }

// resource "aws_acm_certificate" "cf_cert" {
//   count                     = var.cf_certificate_enabled ? 1 : 0
//   provider                  = aws.aws-global
//   domain_name               = var.external_domain_name
//   subject_alternative_names = [
//     "*.${var.external_domain_name}"]
//   validation_method         = "DNS"

//   tags = {
//     Environment = var.env
//   }

//   lifecycle {
//     create_before_destroy = true
//   }
// }

// resource "aws_acm_certificate_validation" "cf_cert" {
//   provider                = aws.aws-global
//   certificate_arn         = aws_acm_certificate.cf_cert.0.arn
//   validation_record_fqdns = [
//     aws_route53_record.cert_validation.fqdn
//   ]
// }

// provider "aws" {
//   region = "us-east-1"
//   alias  = "aws-global"
// }
