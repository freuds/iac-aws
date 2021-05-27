resource "aws_security_group" "haproxy-alb" {
  name        = "sgp-alb-${var.env}-${var.service}-${var.role}"
  description = "SG ${var.env} ${var.service} ${var.role} ALB"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.trusted_networks
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.trusted_networks
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  tags = {
    Name        = "sg-alb-${var.env}-${var.service}-${var.role}"
    Service     = var.service
    Environment = var.env
    Role        = var.role
  }
}

resource "aws_lb" "haproxy" {
  name                             = "alb-${var.service}-${var.role}"
  subnets                          = var.haproxy_alb_subnets
  security_groups                  = [
    aws_security_group.haproxy-alb.id
  ]
  internal                         = var.alb_internal
  load_balancer_type               = var.loadbalancer_type
  enable_cross_zone_load_balancing = var.cross_zone_load_balancing

  access_logs {
    bucket  = var.alb_access_logs_bucket_name
    prefix  = var.alb_access_logs_bucket_prefix
    enabled = var.env == "prod" ? false : var.alb_access_logs_enabled
  }

  tags = {
    Name        = "alb-${var.service}-${var.role}"
    Service     = var.service
    Environment = var.env
    Role        = var.role
    Type        = var.alb_internal ? "internal" : "external"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.haproxy.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.http.arn
  }
}

resource "aws_lb_listener" "https" {
  count             = var.alb_ssl_enabled ? 1 : 0
  load_balancer_arn = aws_lb.haproxy.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
  certificate_arn   = var.alb_ssl_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.http.arn
  }
}

resource "aws_lb" "prod_haproxy" {
  count                            = var.alb_ssl_enabled && var.env == "prod" ? 1 : 0
  name                             = "alb-${var.service}-${var.role}-prod"
  subnets                          = var.haproxy_alb_subnets
  security_groups                  = [
    aws_security_group.haproxy-alb.id
  ]
  internal                         = var.alb_internal
  load_balancer_type               = var.loadbalancer_type
  enable_cross_zone_load_balancing = var.cross_zone_load_balancing

  access_logs {
    bucket  = var.alb_access_logs_bucket_name
    prefix  = var.alb_access_logs_bucket_prefix
    enabled = var.alb_access_logs_enabled
  }

  tags = {
    Name        = "alb-${var.service}-${var.role}-prod"
    Service     = var.service
    Environment = var.env
    Role        = var.role
    Type        = var.alb_internal ? "internal" : "external"
  }
}

resource "aws_lb_listener" "prod_http" {
  count             = var.env == "prod" ? 1 : 0
  load_balancer_arn = aws_lb.prod_haproxy.0.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prod_http.0.arn
  }
}

resource "aws_lb_listener" "prod_https" {
  count             = var.alb_ssl_enabled && var.env == "prod" ? 1 : 0
  load_balancer_arn = aws_lb.prod_haproxy.0.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
  certificate_arn   = var.alb_prod_ssl_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prod_http.0.arn
  }
}

resource "aws_lb_target_group" "http" {
  name     = "${var.env}-tg-${var.service}-${var.role}-http"
  port     = var.haproxy_instances_port
  protocol = var.haproxy_instances_protocol
  vpc_id   = var.vpc_id

  health_check {
    healthy_threshold   = var.healthcheck_healthy_threshold
    unhealthy_threshold = var.healthcheck_unhealthy_threshold
    timeout             = var.healthcheck_timeout
    interval            = var.healthcheck_interval
    path                = var.healthcheck_url
  }

  tags = {
    Name        = "${var.env}-tg-${var.service}-${var.role}-http"
    Service     = var.service
    Environment = var.env
    Role        = var.role
  }
}

resource "aws_lb_target_group" "prod_http" {
  count    = var.env == "prod" ? 1 : 0
  name     = "${var.env}-tg-${var.service}-${var.role}-http-prod"
  port     = var.haproxy_instances_port
  protocol = var.haproxy_instances_protocol
  vpc_id   = var.vpc_id

  health_check {
    healthy_threshold   = var.healthcheck_healthy_threshold
    unhealthy_threshold = var.healthcheck_unhealthy_threshold
    timeout             = var.healthcheck_timeout
    interval            = var.healthcheck_interval
    path                = var.healthcheck_url
  }

  tags = {
    Name        = "${var.env}-tg-${var.service}-${var.role}-http-prod"
    Service     = var.service
    Environment = var.env
    Role        = var.role
  }
}

resource "aws_security_group" "haproxy" {
  name        = "sgp-${var.env}-${var.service}-${var.role}"
  description = "SG ${var.env} ${var.service} ${var.role}"
  vpc_id      = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }

  ingress {
    from_port = var.alb_port_secure
    to_port   = var.alb_port_secure
    protocol  = "TCP"

    security_groups = [
      aws_security_group.haproxy-alb.id
    ]
  }

  ingress {
    from_port = var.alb_port
    to_port   = var.alb_port
    protocol  = "TCP"

    security_groups = [
      aws_security_group.haproxy-alb.id
    ]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  tags = {
    Name        = "sg-${var.env}-${var.service}-${var.role}"
    Service     = var.service
    Environment = var.env
    Role        = var.role
  }
}

data "template_file" "embedded-userdata" {
  template = file("${path.module}/init.tpl")
  vars     = {
    s3_vault_bucket = var.s3_vault_bucket
    aws_resolver_ip = var.vpc_dns_srv_ip
  }
}

data "template_cloudinit_config" "config" {
  gzip          = false
  base64_encode = false

  part {
    content = "#cloud-config\n---\nruncmd:\n - date"
  }

  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.embedded-userdata.rendered
  }

  part {
    content_type = "text/x-shellscript"
    content      = var.extra_userdata
  }

  part {
    content_type = "text/x-shellscript"
    content      = <<EOF
#!/bin/bash
systemctl enable haproxy
systemctl start haproxy
EOF
  }
}

resource "aws_iam_instance_profile" "haproxy" {
  name = "${var.env}-${var.service}-${var.role}-profile"
  role = aws_iam_role.haproxy.name
}

resource "aws_iam_role_policy" "read-aws-users" {
  name   = "${var.service}-read-aws-users"
  role   = aws_iam_role.haproxy.id
  policy = data.aws_iam_policy_document.read-aws-users.json
}

data "aws_iam_policy_document" "read-aws-users" {
  statement {
    actions = [
      "s3:ListBucket"
    ]

    resources = [
      "arn:aws:s3:::${var.s3_vault_bucket}"
    ]
  }

  statement {
    actions = [
      "s3:GetObject"
    ]

    resources = [
      "arn:aws:s3:::${var.s3_vault_bucket}/aws-users.auto.json"
    ]
  }
}

# IAM Role
resource "aws_iam_role" "haproxy" {
  name = var.service
  path = "/"

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

######################## ASG Launch Conf. HAProxy ##############################

resource "aws_launch_configuration" "haproxy" {
  image_id      = var.haproxy_ami_id
  name_prefix   = "lc-${var.env}-${var.service}-${var.role}-"
  instance_type = var.haproxy_instance_type
  key_name      = var.key_name

  root_block_device {
    volume_size = var.haproxy_root_block_device_volume_size
  }

  security_groups = [
    aws_security_group.haproxy.id,
    var.ssh_from_bastion_sg
  ]

  user_data            = data.template_cloudinit_config.config.rendered
  iam_instance_profile = aws_iam_instance_profile.haproxy.name

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "haproxy" {
  count                = var.haproxy_multizone ? var.haproxy_num_zone : 1
  name                 = "${replace(aws_launch_configuration.haproxy.name, "lc-", "asg-")}-${element(lookup(var.azs, var.region), count.index)}"
  launch_configuration = aws_launch_configuration.haproxy.name
  vpc_zone_identifier  = [
    element(var.haproxy_subnets, count.index)]

  target_group_arns = var.env == "prod" ? [
    aws_lb_target_group.http.arn,
    aws_lb_target_group.prod_http.0.arn
  ] : [
    aws_lb_target_group.http.arn
  ]

  lifecycle {
    create_before_destroy = true
  }

  min_size              = var.haproxy_asg_min
  max_size              = var.haproxy_asg_max
  wait_for_elb_capacity = var.haproxy_asg_wait_for_elb_capacity
  desired_capacity      = var.haproxy_asg_desired

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

  /* Common tags */
  tag {
    key                 = "AMI"
    value               = var.haproxy_ami_id
    propagate_at_launch = "true"
  }

  tag {
    key                 = "Name"
    value               = "${var.service}-${var.role}"
    propagate_at_launch = "true"
  }

  tag {
    key                 = "Service"
    value               = var.service
    propagate_at_launch = "true"
  }

  tag {
    key                 = "Environment"
    value               = var.env
    propagate_at_launch = "true"
  }

  tag {
    key                 = "Role"
    value               = var.role
    propagate_at_launch = "true"
  }

  tag {
    key                 = "stop"
    value               = var.start_stop_enabled
    propagate_at_launch = "true"
  }
}

resource "aws_route53_record" "public" {
  count   = !var.alb_internal ? 1 : 0
  zone_id = var.r53_public_zone
  name    = "${var.service}-pub-lb"
  type    = "A"
  alias {
    name                   = aws_lb.haproxy.dns_name
    zone_id                = aws_lb.haproxy.zone_id
    evaluate_target_health = true
  }
}


resource "aws_route53_record" "private" {
  count   = var.alb_internal ? 1 : 0
  zone_id = var.r53_private_zone
  name    = "${var.service}-prv-lb"
  type    = "A"
  alias {
    name                   = aws_lb.haproxy.dns_name
    zone_id                = aws_lb.haproxy.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "alb_aliases_pub" {
  for_each = var.alb_public_aliases
  zone_id  = var.r53_public_zone
  name     = each.key
  type     = "A"
  alias {
    name                   = aws_lb.haproxy.dns_name
    zone_id                = aws_lb.haproxy.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "alb_aliases_private" {
  for_each = var.alb_private_aliases
  zone_id  = var.r53_private_zone
  name     = each.key
  type     = "A"
  alias {
    name                   = aws_lb.haproxy.dns_name
    zone_id                = aws_lb.haproxy.zone_id
    evaluate_target_health = true
  }
}


