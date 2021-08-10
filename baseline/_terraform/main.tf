// Start / Stop
// module "stop_daily" {
//   env                            = var.env
//   name                           = "stop-daily"
//   source                         = "git@github.com:born2scale/terraform-aws-start-stop-scheduler.git"
//   cloudwatch_schedule_expression = "cron(0 18 ? * MON-FRI *)"
//   schedule_action                = "stop"
//   rds_schedule                   = "true"
//   autoscaling_schedule           = "true"

//   resources_tag = {
//     key   = "stop"
//     value = "true"
//   }
// }

// module "start_daily" {
//   env                            = var.env
//   name                           = "start-daily"
//   source                         = "git@github.com:born2scale/terraform-aws-start-stop-scheduler.git"
//   cloudwatch_schedule_expression = "cron(0 6 ? * MON-FRI *)"
//   schedule_action                = "start"
//   rds_schedule                   = "true"
//   autoscaling_schedule           = "true"

//   resources_tag = {
//     key   = "stop"
//     value = "true"
//   }
// }

resource "aws_s3_bucket" "access_log" {
  bucket = format("%s-%s-access-log", var.org_prefix, var.env)
  acl    = "log-delivery-write"

  versioning {
    enabled = var.versioning_enabled
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  lifecycle_rule {
    enabled = var.lifecycle_rule_enabled
    prefix  = var.lifecycle_rule_prefix

    transition {
      days          = var.standard_ia_transition_days
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = var.glacier_transition_days
      storage_class = "GLACIER"
    }

    expiration {
      days = var.expiration_days
    }

    noncurrent_version_transition {
      days          = var.glacier_noncurrent_version_transition_days
      storage_class = "GLACIER"
    }

    noncurrent_version_expiration {
      days = var.noncurrent_version_expiration_days
    }
  }

  force_destroy = var.force_destroy

  tags = var.bucket_tags
}
data "aws_region" "current" {}

resource "aws_s3_bucket_policy" "access_log" {
  bucket = aws_s3_bucket.access_log.id
  policy = data.aws_iam_policy_document.access_log_policy.json
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "access_log_policy" {
  statement {
    sid = "put-object-on-bucket"
    actions = [
      "s3:PutObject"
    ]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.access_log.bucket}/${var.bucket_prefix}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
    ]
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${var.elb_account_id[data.aws_region.current.name]}:root"
      ]
    }
  }
  statement {
    sid = "put-object-from-delivery"
    actions = [
      "s3:PutObject"
    ]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.access_log.bucket}/${var.bucket_prefix}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
    ]
    principals {
      type = "Service"
      identifiers = [
        "delivery.logs.amazonaws.com"
      ]
    }
    condition {
      test = "StringEquals"
      values = [
        "bucket-owner-full-control"
      ]
      variable = "s3:x-amz-acl"
    }
  }
  statement {
    sid = "read-acl-from-delivery"
    actions = [
      "s3:GetBucketAcl"
    ]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.access_log.bucket}"
    ]
    principals {
      type = "Service"
      identifiers = [
        "delivery.logs.amazonaws.com"
      ]
    }
  }
  statement {
    sid = "put-object-from-logdelivery"
    actions = [
      "s3:PutObject"
    ]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.access_log.bucket}/${var.bucket_prefix}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
    ]
    principals {
      type = "Service"
      identifiers = [
        "logdelivery.elb.amazonaws.com"
      ]
    }
    condition {
      test = "StringEquals"
      values = [
        "bucket-owner-full-control"
      ]
      variable = "s3:x-amz-acl"
    }
  }
  // statement {
  //   sid = "read-access-dd-from-lambda"
  //   actions = [
  //     "s3:GetObject"
  //   ]
  //   resources = [
  //     "arn:aws:s3:::${aws_s3_bucket.access_log.bucket}/*"
  //   ]
  //   principals {
  //     type = "AWS"
  //     identifiers = [
  //       "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/datadog-forwarder-role"
  //     ]
  //   }
  // }
}
