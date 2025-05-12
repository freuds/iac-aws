variable "region" {
  default = "eu-west-1"
}

variable "env" {
  default = "qa"
}

variable "s3_origins_paths" {
  default = {
    statics = "/statics/*",
    media   = "/media/*"
  }
}

variable "organization" {
  description = "Name of the organization"
  type        = string
  default     = ""
}
variable "api_http_port" {
  type    = number
  default = 80
}

variable "api_https_port" {
  type    = number
  default = 443
}

variable "api_protocol_policy" {
  type    = string
  default = "https-only"
}

variable "api_ssl_protocols" {
  type    = list(string)
  default = ["TLSv1.1", "TLSv1.2"]
}

variable "viewer_protocol_policy" {
  type    = string
  default = "redirect-to-https"
}

variable "api_keepalive_timeout" {
  type    = number
  default = 60
}

variable "api_read_timeout" {
  type    = number
  default = 60
}

variable "api_aliases_cloudfront" {
  default = ["api.qa.example.com"]
}

variable "api_records" {
  default = ["api"]
}

variable "api_default_ttl" {
  description = "default ttl for api cloudfront cache"
  type        = number
  default     = 3600
}

variable "api_max_ttl" {
  description = "max ttl for api cloudfront cache"
  type        = number
  default     = 7200
}

variable "api_price_class" {
  description = "Price class for api Cloudfront"
  type        = string
  default     = "PriceClass_100"
}

variable "api_allowed_methods" {
  description = "allowed method for api cache behavior"
  type        = list(string)
  default     = ["GET", "HEAD", "OPTIONS", "PUT", "PATCH", "POST", "DELETE"]
}

variable "api_cached_methods" {
  description = "cached method for api cache behavior"
  type        = list(string)
  default     = ["GET", "HEAD", "OPTIONS"]
}

variable "api_forwarded_headers" {
  description = "forwarded headers for api"
  type        = list(string)
  default     = ["Accept-Charset", "Accept-Encoding", "Accept-Language", "Host", "referer", "x-wsse", "_switch_user"]
}

variable "assets_default_ttl" {
  description = "default ttl for assets cloudfront cache"
  type        = number
  default     = 3600
}

variable "assets_max_ttl" {
  description = "max ttl for assets cloudfront cache"
  type        = number
  default     = 7200
}

variable "assets_price_class" {
  description = "Price class for assets on Cloudfront"
  type        = string
  default     = "PriceClass_100"
}

variable "assets_allowed_methods" {
  description = "allowed method for assets ordered cache behavior"
  type        = list(string)
  default     = ["GET", "HEAD", "OPTIONS"]
}

variable "assets_cached_methods" {
  description = "cached method for assets ordered cache behavior"
  type        = list(string)
  default     = ["GET", "HEAD", "OPTIONS"]
}

variable "assets_comment_OAI" {
  default = "origin access identity for QA"
}

variable "assets_aliases_cloudfront" {
  default = ["s.qa.example.com"]
}

variable "asset_record" {
  default = "s"
}

variable "vpc_id" {
  default = "vpc-1234567890"
}

variable "vpc_endpoint_enabled" {
  default = true
}

variable "assets_enable_custom_404" {
  type    = bool
  default = true
}

variable "assets_404_caching_min_ttl" {
  type    = string
  default = 60
}

variable "assets_404_page_path" {
  type    = string
  default = "/statics/errors/404.html"
}

variable "tf_s3_policy_arn" {
  default = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

variable "tf_s3_user_enabled" {
  default = false
}
