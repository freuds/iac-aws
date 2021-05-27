// role iam resource
resource "aws_iam_role" "tf_cloudcraft" {
  name               = "cloudcraft-role"
  tags               = var.tags
  assume_role_policy = data.aws_iam_policy_document.account_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "tf_cloudcraft" {
  role       = aws_iam_role.tf_cloudcraft.name
  policy_arn = aws_iam_policy.tf_cloudcraft.arn
}

data "aws_iam_policy_document" "account_assume_role_policy" {
  statement {
    effect = "Allow"

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${var.cloudcraft_account_id}:root"
      ]
    }

    actions = ["sts:AssumeRole"]

    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values = [
        "${var.cloudcraft_external_id}",
      ]
    }
  }
}

// custom policies actions come from https://help.cloudcraft.co/article/64-minimal-iam-policy
resource "aws_iam_policy" "tf_cloudcraft" {
  name        = "cloudcraft-policy"
  description = "Policy to restrict cloudcraft user"
  policy      = data.aws_iam_policy_document.tf_cloudcraft.json
}

data "aws_iam_policy_document" "tf_cloudcraft" {

  statement {
    sid    = "AllowPolicyForCloudCraft"
    effect = "Allow"
    actions = [
      "apigateway:Get",
      "autoscaling:Describe*",
      "cloudfront:List*",
      "cloudwatch:Describe*",
      "cloudwatch:Get*",
      "cloudwatch:List*",
      "dynamodb:DescribeTable",
      "dynamodb:ListTables",
      "dynamodb:ListTagsOfResource",
      "ec2:Describe*",
      "ecr:Describe*",
      "ecr:List*",
      "ecs:Describe*",
      "ecs:List*",
      "eks:Describe*",
      "eks:List*",
      "elasticache:Describe*",
      "elasticache:List*",
      "elasticfilesystem:Describe*",
      "elasticloadbalancing:Describe*",
      "es:Describe*",
      "es:List*",
      "fsx:Describe*",
      "fsx:List*",
      "kinesis:Describe*",
      "kinesis:List*",
      "lambda:List*",
      "rds:Describe*",
      "rds:ListTagsForResource",
      "redshift:Describe*",
      "route53:List*",
      "s3:GetBucketAcl",
      "s3:GetBucketLocation",
      "s3:GetBucketNotification",
      "s3:GetBucketTagging",
      "s3:GetEncryptionConfiguration",
      "s3:List*",
      "ses:Get*",
      "ses:List*",
      "sns:GetTopicAttributes",
      "sns:List*",
      "sqs:GetQueueAttributes",
      "sqs:ListQueues",
      "tag:Get*"
    ]
    resources = [
      "*",
    ]
  }
}
