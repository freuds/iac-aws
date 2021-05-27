# resource "aws_acm_certificate" "cert" {
#   domain_name       = var.external_domain_name
#   subject_alternative_names = ["*.${var.external_domain_name}"]
#   validation_method = "DNS"

#   tags = {
#     Environment = var.env
#   }

#   lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "aws_route53_record" "cert_validation" {
#   name    = aws_acm_certificate.cert.domain_validation_options.0.resource_record_name
#   type    = aws_acm_certificate.cert.domain_validation_options.0.resource_record_type
#   zone_id = aws_route53_zone.public.id
#   records = [aws_acm_certificate.cert.domain_validation_options.0.resource_record_value]
#   ttl     = 60
# }

# resource "aws_acm_certificate_validation" "cert" {
#   certificate_arn         = aws_acm_certificate.cert.arn
#   validation_record_fqdns = [
#     aws_route53_record.cert_validation.fqdn
#   ]
# }

# data "aws_acm_certificate" "prod" {
#   count = var.env == "prod" ? 1 : 0
#   domain = replace(var.external_domain_name, "${var.env}.", "")
#   most_recent = true
# }
