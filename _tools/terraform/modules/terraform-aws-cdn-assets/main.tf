resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = var.comment_OAI
}

data "aws_s3_bucket" "origin" {
  for_each = var.s3_origins
  bucket   = each.value
}

resource "aws_cloudfront_distribution" "assets_distribution" {
  dynamic "origin" {
    for_each = var.s3_origins
    content {
      domain_name = data.aws_s3_bucket.origin[origin.key].bucket_regional_domain_name
      origin_id   = origin.key

      s3_origin_config {
        origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
      }
    }
  }

  enabled         = true
  aliases         = var.aliases_cloudfront
  is_ipv6_enabled = true

  logging_config {
    include_cookies = false
    bucket          = "${var.s3_bucket_logs}.s3.amazonaws.com"
    prefix          = "cloudfront"
  }

  default_cache_behavior {
    allowed_methods  = [
      "GET",
      "HEAD",
      "OPTIONS"]
    cached_methods   = [
      "GET",
      "HEAD"]
    target_origin_id = keys(var.s3_origins).0

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # Cache behavior with precedence 0
  dynamic "ordered_cache_behavior" {
    for_each = var.s3_origins_paths
    content {
      path_pattern     = ordered_cache_behavior.value
      allowed_methods  = var.allowed_methods
      cached_methods   = var.cached_methods
      target_origin_id = ordered_cache_behavior.key

      forwarded_values {
        query_string = false
        headers      = [
          "Origin"]

        cookies {
          forward = "none"
        }
      }

      min_ttl                = 0
      default_ttl            = var.default_ttl
      max_ttl                = var.max_ttl
      compress               = true
      viewer_protocol_policy = "redirect-to-https"
    }
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

  dynamic "custom_error_response" {
    for_each = range(var.enable_custom_404 ? 1 : 0)

    content {
      response_code         = 404
      error_code            = 404
      error_caching_min_ttl = var.custom_404_caching_min_ttl
      response_page_path    = var.custom_404_page_path
    }
  }
}

resource "aws_route53_record" "assets_route53_record" {
  name    = var.asset_record
  type    = "A"
  zone_id = var.zone_id
  alias {
    evaluate_target_health = false
    name                   = aws_cloudfront_distribution.assets_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.assets_distribution.hosted_zone_id
  }
}