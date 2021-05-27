locals {
  bucket_name = "datadog-forwarder-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}"

  description = "Lambda function to push logs, metrics, and traces to Datadog"
  version_tag = { DD_FORWARDER_VERSION = var.forwarder_version }

  zip_url       = "https://github.com/DataDog/datadog-serverless-functions/releases/download/aws-dd-forwarder-${var.forwarder_version}/aws-dd-forwarder-${var.forwarder_version}.zip"
  zip_name      = "aws-dd-forwarder-${var.forwarder_version}.zip"
  forwarder_zip = "${path.module}/${local.zip_name}"
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

################################################################################
# Forwarder Bucket
################################################################################
resource "aws_s3_bucket" "dd-forwarder" {
  count         = var.create ? 1 : 0
  bucket        = "datadog-forwarder-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}"
  force_destroy = true

  tags = var.tags

  versioning {
    enabled = false
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

################################################################################
# Forwarder IAM Role
################################################################################

data "aws_iam_policy_document" "this" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  count = var.create ? 1 : 0

  name = "datadog-forwarder-role"

  assume_role_policy    = data.aws_iam_policy_document.this.json
  max_session_duration  = var.role_max_session_duration
  permissions_boundary  = var.role_permissions_boundary
  force_detach_policies = true

  tags = merge(var.tags, var.role_tags)
}

resource "aws_iam_policy" "this" {
  count  = var.create ? 1 : 0
  name   = "datadog-forwarder-policy"
  policy = data.aws_iam_policy_document.role_policy.json
}

data "aws_iam_policy_document" "role_policy" {
  statement {
    sid = "AnyResourceAccess"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "tag:GetResources",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
  statement {
    sid = "DatadogBucketFullAccess"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket"
    ]
    resources = [
      "arn:aws:s3:::${local.bucket_name}",
      "arn:aws:s3:::${local.bucket_name}/*"
    ]
  }
  statement {
    sid = "ReadS3Logs"
    actions = [
      "s3:GetObject"
    ]
    resources = [
      var.s3_log_bucket_arn
    ]
  }
}

resource "aws_iam_role_policy_attachment" "this" {
  count = var.create ? 1 : 0

  role       = aws_iam_role.this[0].id
  policy_arn = aws_iam_policy.this[0].id
}

################################################################################
# Forwarder Lambda Function
################################################################################

resource "null_resource" "this" {
  count = var.create ? 1 : 0

  triggers = {
    on_version_change = var.forwarder_version
  }

  provisioner "local-exec" {
    command = "curl --silent -o ${local.forwarder_zip} -L '${local.zip_url}'"
  }
}

resource "aws_s3_bucket_object" "this" {
  count = var.create ? 1 : 0

  bucket = aws_s3_bucket.dd-forwarder[0].bucket
  key    = join("/", compact([var.bucket_prefix, local.zip_name]))
  source = local.forwarder_zip

  content_encoding = "zip"
  content_language = "en-US"
  content_type     = "application/zip"

  storage_class          = var.s3_zip_storage_class
  server_side_encryption = var.s3_zip_server_side_encryption
  metadata               = var.s3_zip_metadata

  tags = merge(var.tags, var.s3_zip_tags, local.version_tag)

  depends_on = [null_resource.this]
}

resource "aws_lambda_function" "this" {
  count = var.create ? 1 : 0

  s3_bucket         = aws_s3_bucket.dd-forwarder[0].bucket
  s3_key            = aws_s3_bucket_object.this[0].key
  s3_object_version = aws_s3_bucket_object.this[0].version_id
  function_name     = var.name
  handler           = "lambda_function.lambda_handler"

  role        = aws_iam_role.this[0].arn
  description = local.description
  runtime     = var.runtime
  layers      = var.layers
  memory_size = var.memory_size
  timeout     = var.timeout
  publish     = var.publish

  reserved_concurrent_executions = var.reserved_concurrent_executions

  environment {
    variables = merge(
      {
        DD_API_KEY                = var.dd_api_key
        DD_ENHANCED_METRICS       = false
        DD_FETCH_LAMBDA_TAGS      = true
        DD_TAGS_CACHE_TTL_SECONDS = 300
        DD_USE_PRIVATE_LINK       = false
        DD_SITE                   = var.dd_site
        DD_S3_BUCKET_NAME         = local.bucket_name
        //DD_LOG_LEVEL              = "debug"
      },
      var.environment_variables,
      local.version_tag
    )
  }

  tags = merge(var.tags, var.lambda_tags, local.version_tag)
}

resource "aws_lambda_permission" "cloudwatch" {
  count = var.create ? 1 : 0

  statement_id   = "datadog-forwarder-CloudWatchLogsPermission"
  action         = "lambda:InvokeFunction"
  function_name  = aws_lambda_function.this[0].function_name
  principal      = "logs.${data.aws_region.current.name}.amazonaws.com"
  //source_arn     = var.s3_log_bucket_arn
  source_account = data.aws_caller_identity.current.account_id
}

resource "aws_lambda_permission" "s3" {
  count = var.create ? 1 : 0

  statement_id  = "datadog-forwarder-S3Permission"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this[0].function_name
  principal     = "s3.amazonaws.com"
  source_arn    = var.s3_log_bucket_arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  count  = var.create ? 1 : 0
  bucket = var.s3_log_bucket_id

  lambda_function {
    lambda_function_arn = aws_lambda_function.this[0].arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "logs/AWSLogs/"
  }

  depends_on = [
    aws_lambda_permission.s3
  ]
}

resource "aws_cloudwatch_log_group" "this" {
  count = var.create ? 1 : 0

  name              = "/aws/lambda/${aws_lambda_function.this[0].function_name}"
  retention_in_days = var.log_retention_days

  tags = var.tags
}