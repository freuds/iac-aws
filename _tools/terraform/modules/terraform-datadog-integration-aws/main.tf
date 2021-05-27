######################## Provider ##############################################
provider "aws" {
  region = var.region
}
data "aws_caller_identity" "current" {}
######################## Datadog IAM Policy ####################################
# Create DatadogAWSIntegrationPolicy
//resource "aws_iam_policy" "datadog" {
//  name        = var.datadog_policy_name
//  path        = "/"
//  description = "Policy for Datadog Access to this AWS Account"
//  policy      = <<POLICY
//{
//  "Version": "2012-10-17",
//  "Statement": [
//    {
//      "Action": [
//        "autoscaling:Describe*",
//        "cloudtrail:DescribeTrails",
//        "cloudtrail:GetTrailStatus",
//        "cloudwatch:Describe*",
//        "cloudwatch:Get*",
//        "cloudwatch:List*",
//        "dynamodb:List*",
//        "dynamodb:Describe*",
//        "ec2:Describe*",
//        "ec2:Get*",
//        "ecs:Describe*",
//        "ecs:List*",
//        "elasticache:Describe*",
//        "elasticache:List*",
//        "elasticloadbalancing:Describe*",
//        "elasticmapreduce:List*",
//        "iam:Get*",
//        "iam:List*",
//        "kinesis:Get*",
//        "kinesis:List*",
//        "kinesis:Describe*",
//        "logs:Get*",
//        "logs:Describe*",
//        "logs:TestMetricFilter",
//        "logs:FilterLogEvents",
//        "rds:Describe*",
//        "rds:List*",
//        "route53:List*",
//        "s3:Get*",
//        "s3:List*",
//        "ses:Get*",
//        "ses:List*",
//        "sns:List*",
//        "sns:Publish",
//        "sqs:GetQueueAttributes",
//        "sqs:ListQueues",
//        "sqs:ReceiveMessage",
//        "sts:AssumeRole",
//        "support:*"
//      ],
//      "Effect": "Allow",
//      "Resource": "*"
//    }
//  ]
//}
//POLICY
//}
//resource "aws_iam_policy" "trail_read_only" {
//  name        = var.trail_policy_read_only_name
//  path        = "/"
//  description = "Policy for Datadog to access CloudTrail RO"
//  policy      = <<POLICY
//{
//  "Version": "2012-10-17",
//  "Statement": [
//    {
//      "Action": [
//        "cloudtrail:GetTrailStatus",
//        "cloudtrail:DescribeTrails",
//        "cloudtrail:LookupEvents",
//        "cloudtrail:ListTags",
//        "s3:ListAllMyBuckets",
//        "kms:ListAliases"
//      ],
//      "Effect": "Allow",
//      "Resource": "*"
//    },
//    {
//      "Action": [
//        "s3:GetObject",
//        "s3:ListBucket",
//        "s3:GetBucketLocation"
//      ],
//      "Effect": "Allow",
//      "Resource": [
//       "arn:aws:s3:::${var.trail_bucket_name}",
//       "arn:aws:s3:::${var.trail_bucket_name}/*"
//      ]
//    }
//  ]
//}
//POLICY
//}
############################# IAM ROLE #########################################
# Create IAM ROLE for datadog
//resource "aws_iam_role" "datadog" {
//  name               = var.datadog_role_name
//  description        = "Role for Datadog Access to this AWS Account"
//  path               = "/"
//  assume_role_policy = <<POLICY
//{
//  "Version": "2012-10-17",
//  "Statement": [
//    {
//      "Effect": "Allow",
//      "Principal": {
//        "AWS": "arn:aws:iam::464622532012:root"
//      },
//      "Action": "sts:AssumeRole",
//      "Condition": {
//        "StringEquals": {
//          "sts:ExternalId": "${var.datadog_policy_external_id}"
//        }
//      }
//    }
//  ]
//}
//POLICY
//}
############################ IAM POLICY ATTACHMENT #############################
//resource "aws_iam_policy_attachment" "datadog_policy_to_datadog_role" {
//  name       = "${var.datadog_policy_name}-attachment"
//  policy_arn = aws_iam_policy.datadog.arn
//  roles      = [
//    aws_iam_role.datadog.name]
//}
//resource "aws_iam_policy_attachment" "trail_policy_to_datadog_role" {
//  name       = "${var.trail_policy_read_only_name}-attachment"
//  policy_arn = aws_iam_policy.trail_read_only.arn
//  roles      = [
//    aws_iam_role.datadog.name]
//}
######################## DATADOG SETUP ##############################################
data "aws_iam_policy_document" "datadog_aws_integration_assume_role" {
  statement {
    actions = [
      "sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [
        "arn:aws:iam::464622532012:root"]
    }
    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"

      values = [
        var.datadog_policy_external_id
      ]
    }
  }
}

data "aws_iam_policy_document" "datadog_aws_integration" {
  statement {
    actions = [
      "autoscaling:Describe*",
      "cloudtrail:DescribeTrails",
      "cloudtrail:GetTrailStatus",
      "cloudwatch:Describe*",
      "cloudwatch:Get*",
      "cloudwatch:List*",
      "dynamodb:List*",
      "dynamodb:Describe*",
      "ec2:Describe*",
      "ec2:Get*",
      "ecs:Describe*",
      "ecs:List*",
      "elasticache:Describe*",
      "elasticache:List*",
      "elasticfilesystem:DescribeAccessPoints",
      "elasticfilesystem:DescribeFileSystems",
      "elasticfilesystem:DescribeTags",
      "elasticloadbalancing:Describe*",
      "elasticmapreduce:List*",
      "iam:Get*",
      "iam:List*",
      "kinesis:Get*",
      "kinesis:List*",
      "kinesis:Describe*",
      "lambda:List*",
      "logs:Get*",
      "logs:Describe*",
      "logs:TestMetricFilter",
      "logs:FilterLogEvents",
      "rds:Describe*",
      "rds:List*",
      "route53:List*",
      "s3:Get*",
      "s3:List*",
      "ses:Get*",
      "ses:List*",
      "sns:List*",
      "sns:Publish",
      "sqs:GetQueueAttributes",
      "sqs:ListQueues",
      "sqs:ReceiveMessage",
      "sts:AssumeRole",
      "support:*",
      "tag:GetResources",
      "tag:GetTagKeys",
      "tag:GetTagValues"
    ]

    resources = [
      "*"]
  }
}

resource "aws_iam_policy" "datadog_aws_integration" {
  name   = "DatadogAWSIntegrationPolicy"
  policy = data.aws_iam_policy_document.datadog_aws_integration.json
}

resource "aws_iam_role" "datadog_aws_integration" {
  name               = "DatadogAWSIntegrationRole"
  description        = "Role for Datadog AWS Integration"
  assume_role_policy = data.aws_iam_policy_document.datadog_aws_integration_assume_role.json
}

resource "aws_iam_role_policy_attachment" "datadog_aws_integration" {
  role       = aws_iam_role.datadog_aws_integration.name
  policy_arn = aws_iam_policy.datadog_aws_integration.arn
}


######################## DATADOG Integration ########################################
# Create a new Datadog - Amazon Web Services integration
resource "datadog_integration_aws" "datadog_aws_integration" {
  account_id  = var.aws_account_id
  role_name   = "DatadogAWSIntegrationRole"
  filter_tags = [
    "Datadog:true"]
  host_tags   = var.host_tags
}