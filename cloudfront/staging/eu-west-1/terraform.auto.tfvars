env                       = "staging"
region                    = "eu-west-1"
assets_comment_OAI        = "origin access identity for phenix-STAGING"
vpc_id                    = "vpc-06a3116bc7568b64b"
api_aliases_cloudfront    = [
  "api.staging.wearephenix.com",
  "app.staging.wearephenix.com",
  "webapp.staging.wearephenix.com"]
api_records               = [
  "api",
  "app",
  "webapp"]
assets_price_class        = "PriceClass_200"
api_price_class           = "PriceClass_200"
assets_aliases_cloudfront = [
  "s.staging.wearephenix.com"]