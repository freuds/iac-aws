variable "s3_origins" {
  description = "Map of s3 origins and bucket names"
  type        = map(string)
  default     = {
    statics = "bucket_name_statics",
    media   = "bucket_name_media"
  }
}

variable "s3_origins_paths" {
  description = "Map of s3 origins and bucket paths"
  type        = map(string)
  default     = {
    statics = "static_path",
    media   = "media_path"
  }
}

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
  default     = [
    "GET",
    "HEAD",
    "OPTIONS"
  ]
}

variable "cached_methods" {
  description = "cached method for ordered cache behavior"
  type        = list(string)
  default     = [
    "GET",
    "HEAD",
    "OPTIONS"
  ]
}

variable "certificate_arn" {
  description = "ARN certificate for Cloudfront"
  type        = string
  default     = ""
}

variable "comment_OAI" {
  description = "comment for origin access identity"
  type        = string
  default     = "Cloudfront origin access"
}

variable "aliases_cloudfront" {
  description = "Alias list for cloudfront distribution"
  type        = list(string)
  default     = [
    "test.com"
  ]
}

variable "zone_id" {
  description = "zone id for route 53 alias record"
  type        = string
  default     = ""
}

variable "asset_record" {
  description = "route 53 record name for assets"
  type        = string
  default     = "assets"
}

variable "enable_custom_404" {
  description = "Enable a custom 404 page"
  type        = bool
  default     = false
}

variable "custom_404_caching_min_ttl" {
  description = "Custom 404 caching min TTL"
  type        = number
  default     = 60
}

variable "custom_404_page_path" {
  description = "Custom 404 page path"
  type        = string
  default     = ""
}