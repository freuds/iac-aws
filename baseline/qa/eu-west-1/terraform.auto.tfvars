env    = "qa"
region = "eu-west-1"

versioning = {
  "status" = "false"
}

lifecycle_rules = [
  {
    id                                     = "log-delivery-write"
    prefix                                 = ""
    enable                                 = true
    abort_incomplete_multipart_upload_days = 7
    transition = [
      {
        transition_period        = 30,
        transition_storage_class = "STANDARD_IA"
      },
      {
        transition_period        = 60,
        transition_storage_class = "GLACIER"
      }
    ]
    noncurrent_version_expiration = [
      {
        days = 90
      }
    ]
    expiration = [
      {
        days = 90
      }
    ]
  }
]


// vpc_id                 = "vpc-01fe3d32b60dd8c9d"
// api_aliases_cloudfront = ["api.qa.example.com", "app.qa.example.com", "webapp.qa.example.com"]
// api_records            = ["api", "app", "webapp"]
// tf_s3_user_enabled     = true
