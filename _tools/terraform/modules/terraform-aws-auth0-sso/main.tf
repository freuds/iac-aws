data "aws_iam_policy_document" "get_caller_identity" {
  statement {
    actions = [
    "sts:GetCallerIdentity"]
    resources = [
    "*"]
  }
}

data "aws_caller_identity" "current" {}

data "terraform_remote_state" "bootstrap" {
  backend = "remote"
  config = {
    organization = "phenix"
    workspaces = {
      name = "bootstrap-admin-eu-west-1"
    }
  }
}

resource "aws_iam_account_alias" "current" {
  account_alias = "${var.org}-${var.env}"
}

resource "aws_iam_policy" "get_caller_identity" {
  name        = "get-caller-identity"
  description = "allows the caller to obtain its own identity"
  policy      = data.aws_iam_policy_document.get_caller_identity.json
}
resource "aws_iam_role" "admin" {
  name                 = var.admin_role_name
  assume_role_policy   = data.aws_iam_policy_document.auth0_assume_role_policy.json
  max_session_duration = var.lifetime_in_seconds
}

resource "aws_iam_role_policy_attachment" "admin" {
  role       = aws_iam_role.admin.name
  policy_arn = aws_iam_policy.get_caller_identity.arn
}

resource "aws_iam_role_policy_attachment" "admin-access-managed" {
  role       = aws_iam_role.admin.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_role" "user" {
  name                 = var.user_role_name
  assume_role_policy   = data.aws_iam_policy_document.auth0_assume_role_policy.json
  max_session_duration = var.lifetime_in_seconds
}

resource "aws_iam_role_policy_attachment" "user" {
  role       = var.user_role_name
  policy_arn = aws_iam_policy.get_caller_identity.arn
}

data "aws_iam_policy_document" "auth0_assume_role_policy" {
  statement {
    actions = [
    "sts:AssumeRole"]

    principals {
      type = "AWS"
      identifiers = [
      "arn:aws:iam::${data.terraform_remote_state.bootstrap.outputs.master_account_id}:root"]
    }
  }
  statement {
    actions = [
    "sts:AssumeRoleWithSAML"]

    condition {
      test     = "StringEquals"
      variable = "SAML:aud"
      values = [
      "https://signin.aws.amazon.com/saml"]
    }

    principals {
      type = "Federated"
      identifiers = [
      aws_iam_saml_provider.auth0-provider.arn]
    }
  }
}

resource "aws_iam_saml_provider" "auth0-provider" {
  depends_on = [
  null_resource.auth0-saml-metadata]
  name                   = "auth0-${replace(var.auth0_domain, ".", "-")}-provider"
  saml_metadata_document = data.local_file.auth0-saml-metadata.content
}

resource "aws_s3_bucket" "vault" {
  bucket = "${var.org}-${var.env}-vault"
  acl    = "public-read"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }

  versioning {
    enabled = true
  }

}

resource "aws_s3_bucket_policy" "b" {
  bucket = aws_s3_bucket.vault.id
  policy = data.aws_iam_policy_document.bucket-policy.json
}

data "aws_vpc_endpoint" "s3" {
  count        = var.vpc_endpoint_enabled ? 1 : 0
  vpc_id       = var.vpc_id
  service_name = "com.amazonaws.${var.region}.s3"
}

data "aws_iam_policy_document" "bucket-policy" {
  statement {
    sid = "read-access-from-auth0"
    actions = [
      "s3:GetObject"
    ]
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.vault.bucket}/*",
    ]
    principals {
      type = "*"
      identifiers = [
        "*"
      ]
    }
    condition {
      test     = "IpAddress"
      variable = "aws:SourceIp"
      values   = var.auth0_ips
    }
  }
  dynamic "statement" {
    for_each = data.aws_vpc_endpoint.s3
    content {
      sid = "read-access-from-vpc-endpoint"
      actions = [
        "s3:GetObject"
      ]
      resources = [
        "arn:aws:s3:::${aws_s3_bucket.vault.bucket}/*"
      ]
      principals {
        type = "*"
        identifiers = [
          "*"
        ]
      }
      condition {
        test     = "StringEquals"
        variable = "aws:sourceVpce"
        values = [
          data.aws_vpc_endpoint.s3.0.id
        ]
      }
    }
  }
}

data "template_file" "aws-users-json" {
  template = file("${path.module}/aws-users.json.tpl")

  vars = {
    aws_users = jsonencode(var.aws_users)
  }
}

data "template_file" "aws-auth0-rule" {
  template = file("${path.module}/aws-auth0-rule.tpl")

  vars = {
    client_id               = var.auth0_client_id,
    admin_arn               = aws_iam_role.admin.arn,
    user_arn                = aws_iam_role.user.arn,
    auth0_provider_arn      = aws_iam_saml_provider.auth0-provider.arn,
    aws_users_bucket_path   = var.aws_users_bucket_path,
    auth0_console_client_id = auth0_client.auth0-console.id,
    auth0_cli_client_id     = auth0_client.auth0-cli.id,
    user_max_lifetime       = var.lifetime_in_seconds
  }
}

resource "aws_s3_bucket_object" "aws-users" {
  bucket  = aws_s3_bucket.vault.bucket
  key     = "aws-users.auto.json"
  content = data.template_file.aws-users-json.rendered
  etag    = md5(data.template_file.aws-users-json.rendered)
}

resource "aws_key_pair" "key_pair" {
  key_name   = var.key_pair_name
  public_key = var.key_pair_public_key
}