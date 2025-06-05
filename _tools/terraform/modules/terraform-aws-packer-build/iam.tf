locals {
  role_name = "packer-build"
}

data "aws_caller_identity" "current" {}

#######################
# IAM Role for Packer
#######################
resource "aws_iam_instance_profile" "packer_build" {
  name = local.role_name
  role = aws_iam_role.packer_build.name
}

data "aws_iam_policy_document" "assume_ec2" {
  statement {
    sid     = "EC2Assume"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "packer_build" {
  name               = local.role_name
  assume_role_policy = data.aws_iam_policy_document.assume_ec2.json

  tags = merge(
    var.tags,
    { "Name" = local.role_name }
  )
}

# Attach managed Policies
resource "aws_iam_role_policy_attachment" "SSM_permissions" {
  role       = aws_iam_role.packer_build.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
