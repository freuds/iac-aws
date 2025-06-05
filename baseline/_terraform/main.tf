data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

// Start / Stop
// module "stop_daily" {
//   env                            = var.env
//   name                           = "stop-daily"
//   source                         = "git@github.com:example/terraform-aws-start-stop-scheduler.git"
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
//   source                         = "git@github.com:example/terraform-aws-start-stop-scheduler.git"
//   cloudwatch_schedule_expression = "cron(0 6 ? * MON-FRI *)"
//   schedule_action                = "start"
//   rds_schedule                   = "true"
//   autoscaling_schedule           = "true"

//   resources_tag = {
//     key   = "stop"
//     value = "true"
//   }
// }

#-------------------------------
# S3 Bucket Access Logs
#-------------------------------
locals {
  bucket_name = format("%s-%s-access-log", var.org_prefix, var.env)
}
module "access_log" {
  source      = "git@github.com:example/terraform-aws-s3-bucket.git"
  bucket_name = local.bucket_name
  bucket_tags = var.bucket_tags
  environment = var.env

  versioning     = var.versioning
  lifecycle_rule = var.lifecycle_rule
  extra_policy   = data.aws_iam_policy_document.access_log.json
}

#-------------------------------
# S3 Bucket Access Logs
#-------------------------------
data "aws_iam_policy_document" "access_log" {
  statement {
    sid = "put-object-on-bucket"
    actions = [
      "s3:PutObject"
    ]
    resources = [
      format("arn:aws:s3:::%s/%s/AWSLogs/%s/*", local.bucket_name, var.bucket_prefix, data.aws_caller_identity.current.account_id)
    ]
    principals {
      type = "AWS"
      identifiers = [
        format("arn:aws:iam::%s:root", try(var.elb_account_id[data.aws_region.current.name], data.aws_caller_identity.current.account_id))
      ]
    }
  }
  statement {
    sid = "put-object-from-delivery"
    actions = [
      "s3:PutObject"
    ]
    resources = [
      format("arn:aws:s3:::%s/%s/AWSLogs/%s/*", local.bucket_name, var.bucket_prefix, data.aws_caller_identity.current.account_id)
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
      format("arn:aws:s3:::%s", local.bucket_name)
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
      format("arn:aws:s3:::%s/%s/AWSLogs/%s/*", local.bucket_name, var.bucket_prefix, data.aws_caller_identity.current.account_id)
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
}
