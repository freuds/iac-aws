module "cdn-api" {
  source                   = "git@github.com:xxxxxxxx/terraform-cdn-api.git"
  env                      = var.env
  region                   = var.region
  s3_origins_paths         = var.s3_origins_paths
  s3_bucket_logs           = data.terraform_remote_state.baseline.outputs.s3_access_log_bucket_id
  origin_domain_name       = data.terraform_remote_state.varnish.outputs.varnish_alb_dns_name
  origin_http_port         = var.api_http_port
  origin_https_port        = var.api_https_port
  origin_protocol_policy   = var.api_protocol_policy
  origin_ssl_protocols     = var.api_ssl_protocols
  viewer_protocol_policy   = var.viewer_protocol_policy
  origin_keepalive_timeout = var.api_keepalive_timeout
  origin_read_timeout      = var.api_read_timeout
  default_ttl              = var.api_default_ttl
  max_ttl                  = var.api_max_ttl
  price_class              = var.api_price_class
  allowed_methods          = var.api_allowed_methods
  cached_methods           = var.api_cached_methods
  forwarded_headers        = var.api_forwarded_headers
  certificate_arn          = data.aws_acm_certificate.api_cloudfront_certificate.arn
  aliases_cloudfront       = var.api_aliases_cloudfront
  zone_id                  = data.terraform_remote_state.vpc.outputs.r53_public_zone_id
  api_records              = var.api_records
}

// module "cdn-assets" {
//   source = "git@github.com:xxxxxxx/terraform-cdn-assets.git"
//   env    = var.env
//   region = var.region
//   s3_origins = {
//     statics = aws_s3_bucket.static-bucket.id,
//     media   = aws_s3_bucket.media-bucket.id,
//   }
//   s3_origins_paths           = var.s3_origins_paths
//   s3_bucket_logs             = data.terraform_remote_state.baseline.outputs.s3_access_log_bucket_id
//   default_ttl                = var.assets_default_ttl
//   max_ttl                    = var.assets_max_ttl
//   price_class                = var.assets_price_class
//   allowed_methods            = var.assets_allowed_methods
//   cached_methods             = var.assets_cached_methods
//   certificate_arn            = data.aws_acm_certificate.assets_cloudfront_certificate.arn
//   comment_OAI                = var.assets_comment_OAI
//   aliases_cloudfront         = var.assets_aliases_cloudfront
//   zone_id                    = data.terraform_remote_state.vpc.outputs.r53_public_zone_id
//   asset_record               = var.asset_record
//   enable_custom_404          = var.assets_enable_custom_404
//   custom_404_caching_min_ttl = var.assets_404_caching_min_ttl
//   custom_404_page_path       = var.assets_404_page_path
// }

data "aws_acm_certificate" "api_cloudfront_certificate" {
  provider = aws.aws-global
  domain   = data.terraform_remote_state.vpc.outputs.public_domain
}

data "aws_acm_certificate" "assets_cloudfront_certificate" {
  provider = aws.aws-global
  domain   = data.terraform_remote_state.vpc.outputs.public_domain
}

resource "aws_s3_bucket" "media-bucket" {
  bucket = "s3-${var.env}-media"
  versioning {
    enabled = true
  }

  lifecycle_rule {
    id      = "lifecycle rule for media"
    enabled = true

    noncurrent_version_transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    noncurrent_version_transition {
      days          = 60
      storage_class = "GLACIER"
    }

    noncurrent_version_expiration {
      days = 90
    }
  }
}

resource "aws_s3_bucket_policy" "media_bucket_policy" {
  depends_on = [
  aws_s3_bucket.media-bucket]
  bucket = aws_s3_bucket.media-bucket.id
  policy = data.aws_iam_policy_document.media_bucket_policy.json
}

data "aws_iam_policy_document" "media_bucket_policy" {
  statement {
    principals {
      identifiers = [module.cdn-assets.origin_access_identity_arn]
      type        = "AWS"
    }

    actions   = ["s3:GetObject", "s3:ListBucket"]
    resources = ["arn:aws:s3:::${aws_s3_bucket.media-bucket.id}", "arn:aws:s3:::${aws_s3_bucket.media-bucket.id}/*"]
  }

  statement {
    principals {
      identifiers = ["*"]
      type        = "AWS"
    }

    actions   = ["s3:GetObject", "s3:ListBucket", "s3:PutObject"]
    resources = ["arn:aws:s3:::${aws_s3_bucket.media-bucket.id}", "arn:aws:s3:::${aws_s3_bucket.media-bucket.id}/*"]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceVpce"
      values   = [data.aws_vpc_endpoint.s3.0.id]
    }
  }
}

resource "aws_s3_bucket" "static-bucket" {
  bucket = "s3-${var.env}-static"
}

resource "aws_s3_bucket_policy" "static_bucket_policy" {
  depends_on = [
  aws_s3_bucket.static-bucket]
  bucket = aws_s3_bucket.static-bucket.id
  policy = data.aws_iam_policy_document.static_bucket_policy.json
}

data "aws_vpc_endpoint" "s3" {
  count        = var.vpc_endpoint_enabled ? 1 : 0
  vpc_id       = var.vpc_id
  service_name = "com.amazonaws.${var.region}.s3"
}

data "aws_iam_policy_document" "static_bucket_policy" {
  statement {
    principals {
      identifiers = [module.cdn-assets.origin_access_identity_arn]
      type        = "AWS"
    }

    actions   = ["s3:GetObject", "s3:ListBucket"]
    resources = ["arn:aws:s3:::${aws_s3_bucket.static-bucket.id}", "arn:aws:s3:::${aws_s3_bucket.static-bucket.id}/*"]
  }
  statement {
    principals {
      identifiers = ["*"]
      type        = "AWS"
    }

    actions   = ["s3:GetObject", "s3:ListBucket", "s3:PutObject"]
    resources = ["arn:aws:s3:::${aws_s3_bucket.static-bucket.id}", "arn:aws:s3:::${aws_s3_bucket.static-bucket.id}/*"]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceVpce"
      values = [data.aws_vpc_endpoint.s3.0.id
      ]
    }
  }
}

resource "aws_iam_user" "tf-s3" {
  count = var.tf_s3_user_enabled ? 1 : 0
  name  = "${var.env}-tf-s3-iam-user"
}

resource "aws_iam_access_key" "tf-s3" {
  count = var.tf_s3_user_enabled ? 1 : 0
  user  = aws_iam_user.tf-s3[count.index].name
}

resource "aws_iam_user_policy_attachment" "tf-s3" {
  count      = var.tf_s3_user_enabled ? 1 : 0
  user       = aws_iam_user.tf-s3[count.index].name
  policy_arn = var.tf_s3_policy_arn
}
