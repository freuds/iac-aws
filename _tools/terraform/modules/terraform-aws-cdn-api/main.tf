resource "aws_cloudfront_distribution" "api_distribution" {
  enabled         = true
  aliases         = var.aliases_cloudfront
  is_ipv6_enabled = true

  logging_config {
    include_cookies = false
    bucket          = "${var.s3_bucket_logs}.s3.amazonaws.com"
    prefix          = "cloudfront"
  }

  origin {
    domain_name = var.origin_domain_name
    origin_id   = "api"

    custom_origin_config {
      http_port                = var.origin_http_port
      https_port               = var.origin_https_port
      origin_protocol_policy   = var.origin_protocol_policy
      origin_ssl_protocols     = var.origin_ssl_protocols
      origin_keepalive_timeout = var.origin_keepalive_timeout
      origin_read_timeout      = var.origin_read_timeout
    }
  }

  default_cache_behavior {
    allowed_methods  = var.allowed_methods
    cached_methods   = var.cached_methods
    target_origin_id = "api"

    forwarded_values {
      query_string = true
      headers      = var.forwarded_headers

      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = var.viewer_protocol_policy
    min_ttl                = 0
    default_ttl            = var.default_ttl
    max_ttl                = var.max_ttl
  }

  price_class = var.price_class

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Environment = var.env
  }

  viewer_certificate {
    acm_certificate_arn      = var.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.1_2016"
  }
}

resource "aws_route53_record" "api_route53_record" {
  count = length(var.api_records)

  name    = var.api_records[count.index]
  type    = "A"
  zone_id = var.zone_id

  alias {
    evaluate_target_health = false
    name                   = aws_cloudfront_distribution.api_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.api_distribution.hosted_zone_id
  }
}