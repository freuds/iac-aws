########################################
# SG bastion ssh ingress
########################################
resource "aws_security_group" "bastion" {
  name        = "sgp-${var.env}-${var.service}"
  vpc_id      = var.vpc_id
  description = "Bastion security group (only SSH inbound access is allowed)"
  ingress {
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = var.cidr_blocks
  }
  tags = {
    Name        = "sgp-${var.env}-${var.service}",
    Service     = var.service
    Environment = var.env
  }
  lifecycle {
    create_before_destroy = true
  }
}

########################################
# SG bastion ssh egress
########################################
resource "aws_security_group" "allow-all-egress" {
  name        = "sgp-allow-all-egress"
  vpc_id      = var.vpc_id
  description = "All outbound security group (all outbound is allowed)"
  egress {
    from_port   = var.outbound_port
    to_port     = var.outbound_port
    protocol    = "-1"
    cidr_blocks = var.outbound_cidr_blocks
  }
  tags = {
    Name        = "sgp-allow-all-egress",
    Service     = var.service
    Environment = var.env
  }
  lifecycle {
    create_before_destroy = true
  }
}

########################################
# SG bastion ssh from bastion
########################################
resource "aws_security_group" "ssh-from-bastion" {
  name        = "sgp-ssh-from-bastion"
  description = "Allow all ssh from remote bastion servers"
  vpc_id      = var.vpc_id
  ingress {
    from_port = var.ssh_port
    to_port   = var.ssh_port
    protocol  = "tcp"
    security_groups = [
    aws_security_group.bastion.id]
  }
  tags = {
    Name        = "sgp-ssh-from-bastion",
    Service     = var.service
    Environment = var.env
  }
  lifecycle {
    create_before_destroy = true
  }
}

########################################
# Userdata init script
########################################
data "template_file" "embedded_userdata" {
  template = file("${path.module}/init.tpl")

}

########################################
# Userdata init script
########################################
data "template_cloudinit_config" "config" {
  gzip          = false
  base64_encode = false

  part {
    content = "#cloud-config\n---\nruncmd:\n - date"
  }

  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.embedded_userdata.rendered
  }

  part {
    content_type = "text/x-shellscript"
    content      = var.extra_userdata
  }
}

########################################
# Launch Configuration bastion
########################################
resource "aws_launch_configuration" "bastion" {
  name_prefix          = "lc-${var.env}-${var.service}"
  image_id             = var.ami
  instance_type        = var.instance_type
  user_data            = data.template_cloudinit_config.config.rendered
  key_name             = var.root_keypair
  iam_instance_profile = aws_iam_instance_profile.bastion-instance-profile.name
  security_groups = [
    aws_security_group.bastion.id,
  aws_security_group.allow-all-egress.id]
  lifecycle {
    create_before_destroy = true
  }
}

########################################
# ASG bastion
########################################
resource "aws_autoscaling_group" "bastion" {
  name = replace(aws_launch_configuration.bastion.name, "lc-", "asg-")
  # availability_zones        = var.azs
  desired_capacity          = var.asg_desired_capacity
  min_size                  = var.asg_min_size
  max_size                  = var.asg_max_size
  health_check_grace_period = "60"
  health_check_type         = "EC2"
  wait_for_capacity_timeout = 0
  launch_configuration      = aws_launch_configuration.bastion.name
  vpc_zone_identifier       = var.subnet_ids

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances",
  ]

  tags = [
    {
      Name                = format("%s-%s", var.env, var.service)
      propagate_at_launch = true
      Service             = var.service
    }
  ]

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      tags,
    ]
  }
}

########################################
# EIP bastion
########################################
resource "aws_eip" "eip_bastion" {
  tags = {
    Name    = "bastion-eip"
    Service = var.service
  }
}

resource "aws_iam_role_policy" "attach-eip" {
  name   = "${var.service}-attach-eip"
  role   = aws_iam_role.bastion-role.id
  policy = data.aws_iam_policy_document.attach-eip.json
}

data "aws_iam_policy_document" "attach-eip" {
  statement {
    actions = [
      "ec2:AssociateAddress",
      "ec2:DescribeAddresses",
      "ec2:DescribeInstances",
      "ec2:DisassociateAddress"
    ]

    resources = [
    "*"]
  }
}

########################################
# Route53 record bastion
########################################
resource "aws_route53_record" "public_dns_bastion" {
  zone_id = var.aws_route53_zone_public_id
  name    = var.service
  type    = "A"
  ttl     = var.r53_pub_ttl
  records = [
  aws_eip.eip_bastion.public_ip]
}


########################################
# IAM instance profile bastion
########################################
resource "aws_iam_instance_profile" "bastion-instance-profile" {
  name = "bastion-instance-iam-profile"
  role = aws_iam_role.bastion-role.name
}

########################################
# IAM role for bastion
########################################
resource "aws_iam_role" "bastion-role" {
  name = "bastion-role"
  # assume_role_policy = aws_iam_policy_document.bastion-role.json

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

# resource "aws_iam_role_policy" "bastion-role" {
#   name   = "${var.service}-bastion-role"
#   role   = aws_iam_role.bastion-role.id
#   policy = data.aws_iam_policy_document.bastion-role.json
# }

# data "aws_iam_policy_document" "bastion-role" {
#   statement {
#     actions = [
#       "sts:AssumeRole"
#     ]
#     principals {
#       type        = "Service"
#       identifiers = ["ec2.amazonaws.com"]
#     }
#     resources = [
#       "*"
#     ]
#   }
# }

########################################
# IAM role policy for bastion
########################################
# resource "aws_iam_role_policy" "read-aws-users" {
#   name   = "${var.service}-read-aws-users"
#   role   = aws_iam_role.bastion-role.id
#   policy = data.aws_iam_policy_document.read-aws-users.json
# }

# data "aws_iam_policy_document" "read-aws-users" {
#   statement {
#     actions = [
#       "s3:ListBucket"
#     ]

#     resources = [
#       "arn:aws:s3:::${var.s3_vault_bucket}"
#     ]
#   }

#   statement {
#     actions = [
#       "s3:GetObject"
#     ]

#     resources = [
#       "arn:aws:s3:::${var.s3_vault_bucket}/aws-users.auto.json"
#     ]
#   }
# }
