data "aws_region" "current" {}

############### IAM CONFIG ############
resource "aws_iam_role" "start_stop_scheduler" {
  name               = "${var.env}-${var.name}-lambda-scheduler"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "lambda.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "schedule_autoscaling" {
  name   = "${var.env}-lambda-scheduler-autoscaling"
  role   = aws_iam_role.start_stop_scheduler.id
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "autoscaling:DescribeScalingProcessTypes",
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DescribeTags",
                "autoscaling:SuspendProcesses",
                "autoscaling:ResumeProcesses",
                "autoscaling:UpdateAutoScalingGroup",
                "autoscaling:DescribeAutoScalingInstances",
                "autoscaling:TerminateInstanceInAutoScalingGroup",
                "ec2:TerminateInstances"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "schedule_ec2" {
  name  = "${var.env}-lambda-scheduler-ec2"
  role  = aws_iam_role.start_stop_scheduler.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "ec2:DescribeInstances",
                "ec2:DescribeInstanceStatus",
                "ec2:StopInstances",
                "ec2:StartInstances",
                "ec2:DescribeTags",
                "ec2:TerminateSpotInstances"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "schedule_rds" {
  name = "${var.env}-lambda-scheduler-rds"
  role = aws_iam_role.start_stop_scheduler.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "rds:ListTagsForResource",
                "rds:DescribeDBClusters",
                "rds:StartDBCluster",
                "rds:StopDBCluster",
                "rds:DescribeDBInstances",
                "rds:StartDBInstance",
                "rds:StopDBInstance"
            ],
            "Effect": "Allow",
            "Resource": "*"
        }
    ]
}
EOF
}

data "archive_file" "source" {
  type        = "zip"
  source_dir  = "${path.module}/package/"
  output_path = "${path.module}/aws-stop-start-resources.zip"
}

resource "aws_lambda_function" "start_stop_scheduler" {
  filename         = data.archive_file.source.output_path
  function_name    = "${var.env}-${var.name}-lambda-scheduler"
  role             = aws_iam_role.start_stop_scheduler.arn
  handler          = "scheduler.main.lambda_handler"
  source_code_hash = data.archive_file.source.output_base64sha256
  runtime          = "python3.7"
  timeout          = "600"

  environment {
    variables = {
      AWS_REGIONS          = data.aws_region.current.name
      SCHEDULE_ACTION      = var.schedule_action
      TAG_KEY              = var.resources_tag["key"]
      TAG_VALUE            = var.resources_tag["value"]
      RDS_SCHEDULE         = var.rds_schedule
      AUTOSCALING_SCHEDULE = var.autoscaling_schedule
    }
  }

  tags = {
    Environment = var.env
  }
}

resource "aws_cloudwatch_event_rule" "start_stop" {
  name                = "trigger-${var.name}-lambda-scheduler"
  description         = "Trigger lambda start stop scheduler"
  schedule_expression = var.cloudwatch_schedule_expression
}

resource "aws_cloudwatch_event_target" "start_stop" {
  arn  = aws_lambda_function.start_stop_scheduler.arn
  rule = aws_cloudwatch_event_rule.start_stop.name
}

resource "aws_lambda_permission" "start_stop" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  principal     = "events.amazonaws.com"
  function_name = aws_lambda_function.start_stop_scheduler.function_name
  source_arn    = aws_cloudwatch_event_rule.start_stop.arn
}

locals {
  lambda_logging_policy = {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource": "${aws_cloudwatch_log_group.start_stop.arn}",
        "Effect": "Allow"
      }
    ]
  }
}

resource "aws_iam_role_policy" "lambda_logging" {
  name   = "${var.env}-${var.name}-lambda-logging"
  role   = aws_iam_role.start_stop_scheduler.id
  policy = jsonencode(local.lambda_logging_policy)
}

resource "aws_cloudwatch_log_group" "start_stop" {
  name              = "/aws/lambda/${var.env}-${var.name}"
  retention_in_days = 14
}

