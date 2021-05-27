resource "aws_organizations_organization" "org" {
  aws_service_access_principals = var.service_access_principals
  feature_set                   = "ALL"
}

resource "aws_organizations_account" "account" {
  depends_on = [aws_organizations_organization.org]
  count                      = length(keys(var.accounts))
  name                       = "${var.org_prefix}-${element(keys(var.accounts), count.index)}"
  email                      = element(values(var.accounts), count.index)
  iam_user_access_to_billing = var.iam_access_to_billing
  role_name                  = var.iam_admin_role_name
  parent_id                  = aws_organizations_organization.org.roots.0.id
}

resource "aws_s3_bucket" "cloudtrail" {
  bucket = "${var.org_prefix}-trail"
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSCloudTrailAclCheck",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "arn:aws:s3:::${var.org_prefix}-trail"
        },
        {
            "Sid": "AWSCloudTrailWrite",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::${var.org_prefix}-trail/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        }
    ]
}
POLICY
}

resource "aws_cloudtrail" "main" {
  name                  = "${var.org_prefix}-trail"
  s3_bucket_name        = "${var.org_prefix}-trail"
  is_organization_trail = true
  is_multi_region_trail = var.org_multi_region_trail
}

resource "aws_iam_user" "tf-cloud" {
  name = "${var.env}-tf-cloud-iam-user"
}

resource "aws_iam_access_key" "tf-cloud" {
  user = aws_iam_user.tf-cloud.name
}

resource "aws_iam_user_policy_attachment" "tf-cloud" {
  user       = aws_iam_user.tf-cloud.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}