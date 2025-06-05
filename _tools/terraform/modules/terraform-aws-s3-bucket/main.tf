locals {
  status = {
    enabled  = "Enabled",
    disabled = "Disabled"
  }

  storage_class = {
    standard            = "STANDARD",
    standard_ia         = "STANDARD_IA",
    onezone_ia          = "ONEZONE_IA",
    intelligent_tiering = "INTELLIGENT_TIERING",
    glacier             = "INTELLIGENT_TIERING",
    glacier_ir          = "GLACIER_IR",
    deep_archive        = "DEEP_ARCHIVE"
  }
  # Bucket policy forbidding file transfer out of VPC Endpoints
  force_encrypted_uploads = var.force_encrypted_uploads ? { "key" : "value" } : {}
}

# Extra policy for bucket
data "aws_iam_policy_document" "bucket_policy" {
  count                   = var.extra_policy != "" ? 1 : 0
  source_policy_documents = [var.extra_policy]
}

resource "aws_s3_bucket_policy" "policy" {
  count  = length(data.aws_iam_policy_document.bucket_policy)
  bucket = aws_s3_bucket.encrypted_bucket.id
  policy = data.aws_iam_policy_document.bucket_policy[0].json
}

resource "aws_s3_bucket" "encrypted_bucket" {
  bucket        = var.bucket_name
  force_destroy = var.force_destroy

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    {
      "Name" = var.bucket_name
    },
    var.bucket_tags,
  )
}

resource "aws_s3_bucket_ownership_controls" "object_ownership" {
  bucket = aws_s3_bucket.encrypted_bucket.id
  rule {
    object_ownership = var.object_ownership
  }
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.encrypted_bucket.id

  versioning_configuration {
    # Valid values: "Enabled" or "Suspended"
    status = try(var.versioning["enabled"] ? "Enabled" : "Suspended", tobool(var.versioning["status"]) ? "Enabled" : "Suspended", title(lower(var.versioning["status"])))
    # Valid values: "Enabled" or "Disabled"
    mfa_delete = try(tobool(var.versioning["mfa_delete"]) ? "Enabled" : "Disabled", title(lower(var.versioning["mfa_delete"])), null)
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.encrypted_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "lifecycle" {
  # Only one lifecycle_configuration per bucket is allowed
  bucket = aws_s3_bucket.encrypted_bucket.id

  dynamic "rule" {
    for_each = var.lifecycle_rules
    content {
      id     = lookup(rule.value, "id", null)
      status = lookup(rule.value, "enable", null) ? local.status.enabled : local.status.disabled

      # Case 1 : Simple filter based on prefix only, to stay compatible with the existing usage of the CrossModule Bucket
      dynamic "filter" {
        for_each = length(try(rule.value.prefix, "")) > 0 ? { prefix = rule.value.prefix } : {}

        content {
          prefix = try(rule.value.prefix, null)
        }
      }

      # Case 2 : Dedicated filter map with only one parameter
      dynamic "filter" {
        for_each = [
          for v in try(flatten([rule.value.filter]), []) : v
          if max(length(keys(v)), length(try(rule.value.filter.tags, rule.value.filter.tag, []))) == 1
        ]

        content {
          object_size_greater_than = try(filter.value["object_size_greater_than"], null)
          object_size_less_than    = try(filter.value["object_size_less_than"], null)
          prefix                   = try(filter.value["prefix"], null)

          dynamic "tag" {
            for_each = try(filter.value["tags"], filter.value["tag"], [])

            content {
              key   = tag.key
              value = tag.value
            }
          }
        }
      }

      # Case 3 : Dedicated filter map with multiple parameters
      dynamic "filter" {
        for_each = [
          for v in try(flatten([rule.value.filter]), []) : v
          if max(length(keys(v)), length(try(rule.value.filter.tags, rule.value.filter.tag, []))) > 1
        ]

        content {
          and {
            object_size_greater_than = try(filter.value["object_size_greater_than"], null)
            object_size_less_than    = try(filter.value["object_size_less_than"], null)
            prefix                   = try(filter.value["prefix"], null)
            tags                     = try(filter.value["tags"], filter.value["tag"], null)
          }
        }
      }

      # Max 1 block - abort_incomplete_multipart_upload
      dynamic "abort_incomplete_multipart_upload" {
        for_each = try([rule.value.abort_incomplete_multipart_upload_days], [])

        content {
          days_after_initiation = try(rule.value.abort_incomplete_multipart_upload_days, null)
        }
      }

      # Max 1 block - expiration
      dynamic "expiration" {
        for_each = try(flatten([rule.value.expiration]), [])

        content {
          date                         = try(expiration.value.date, null)
          days                         = try(expiration.value.days, null)
          expired_object_delete_marker = try(expiration.value.expired_object_delete_marker, null)
        }
      }

      # Max 1 block - noncurrent_version_expiration
      dynamic "noncurrent_version_expiration" {
        for_each = try(flatten([rule.value.noncurrent_version_expiration]), [])

        content {
          newer_noncurrent_versions = try(noncurrent_version_expiration.value.newer_noncurrent_versions, null)
          noncurrent_days           = try(noncurrent_version_expiration.value.days, noncurrent_version_expiration.value.noncurrent_days, null)
        }
      }

      dynamic "transition" {
        for_each = lookup(rule.value, "transition", [])
        content {
          days          = lookup(transition.value, "transition_period", null)
          storage_class = lookup(transition.value, "transition_storage_class", null)
        }
      }

      dynamic "noncurrent_version_transition" {
        for_each = lookup(rule.value, "versions_transition", [])
        content {
          noncurrent_days = lookup(noncurrent_version_transition.value, "transition_period", null)
          storage_class   = lookup(noncurrent_version_transition.value, "transition_storage_class", null)
        }
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "bucket" {
  bucket                  = aws_s3_bucket.encrypted_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}
