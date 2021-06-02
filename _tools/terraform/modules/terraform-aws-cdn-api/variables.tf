variable "s3_bucket_logs" {
  description = "s3 bucket name hosting logs"
  type        = string
  default     = ""
}

variable "env" {
  description = "environment"
  type        = string
  default     = ""
}

variable "default_ttl" {
  description = "default ttl for cloudfront cache"
  type        = number
  default     = 86400
}

variable "max_ttl" {
  description = "max ttl for cloudfront cache"
  type        = number
  default     = 31536000
}

variable "price_class" {
  description = "Price class for Cloudfront"
  type        = string
  default     = "PriceClass_200"
}

variable "allowed_methods" {
  description = "allowed method for ordered cache behavior"
  type        = list(string)
  default     = ["GET", "HEAD", "OPTIONS"]
}

variable "cached_methods" {
  description = "cached method for ordered cache behavior"
  type        = list(string)
  default     = ["GET", "HEAD", "OPTIONS"]
}

variable "forwarded_headers" {
  description = "list of forwarded headers"
  type        = list(string)
  default     = ["Host"]
}

variable "certificate_arn" {
  description = "ARN certificate for Cloudfront"
  type        = string
  default     = ""
}

variable "aliases_cloudfront" {
  description = "Alias list for cloudfront distribution"
  type        = list(string)
  default     = ["test.com"]
}

variable "viewer_protocol_policy" {
  description = "Protocol that users can use to access the files in the origin. One of allow-all, https-only, redirect-to-https"
  type        = string
  default     = "redirect-to-https"
}

variable "origin_domain_name" {
  description = "API origin for the CloudFront distribution"
  type        = string
  default     = "test.com"
}

variable "origin_http_port" {
  description = "HTTP port for the origin"
  type        = number
  default     = 80
}

variable "origin_https_port" {
  description = "HTTPS port for the origin"
  type        = number
  default     = 443
}

variable "origin_protocol_policy" {
  description = "The origin protocol policy to apply to your origin, one of http-only, https-only, match-viewer"
  type        = string
  default     = ""
}

variable "origin_ssl_protocols" {
  description = "The SSL protocols to use when talking to the origin. A list of values in: SSLv3, TLSv1, TLSv1.1, TLSv1.2"
  type        = list(string)
  default     = ["TLSv1.1", "TLSv1.2"]
}

variable "origin_keepalive_timeout" {
  description = "Custom connection KeepAlive timeout in seconds"
  type        = number
  default     = 60
}

variable "origin_read_timeout" {
  description = "Custom connection read timeout in seconds"
  type        = number
  default     = 60
}

variable "zone_id" {
  description = "zone id for route 53 alias record"
  type        = string
  default     = ""
}

variable "api_records" {
  description = "route 53 record names for cloudfront api"
  type        = list(string)
  default     = ["api"]
}