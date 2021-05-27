resource "aws_efs_file_system" "efs-fs" {
  performance_mode = var.performance_mode
  throughput_mode  = var.throughput_mode
  tags             = {
    Name        = "${var.env}-${var.service}-${var.role}"
    Environment = var.env
    Service     = var.service
    Role        = var.role
  }
}

resource "aws_efs_access_point" "efs-ap" {
  file_system_id = aws_efs_file_system.efs-fs.id
  posix_user {
    gid            = var.user_gid
    uid            = var.user_uid
    secondary_gids = var.secondary_gids
  }
  root_directory {
    path = var.ap_root_dir_path
    creation_info {
      owner_gid   = var.owner_gid
      owner_uid   = var.owner_uid
      permissions = var.permissions
    }
  }
}

resource "aws_efs_mount_target" "mount-efs" {
  count = length(var.private_subnet_ids)

  file_system_id = aws_efs_file_system.efs-fs.id
  subnet_id      = element(var.private_subnet_ids, count.index)

  security_groups = [
    aws_security_group.efs-sg.id
  ]
}

resource "aws_security_group" "efs-sg" {
  name        = "sgp-${var.env}-${var.service}-${var.role}"
  description = "Allows NFS traffic from/to ${var.env}-${var.service}-${var.role}."
  vpc_id      = var.vpc_id

  ingress {
    from_port = 2049
    to_port   = 2049
    protocol  = "tcp"

    security_groups = var.ingress_security_group_ids
  }

  egress {
    from_port = 2049
    to_port   = 2049
    protocol  = "tcp"

    security_groups = var.egress_security_group_ids
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name        = "sgp-${var.env}-${var.service}-${var.role}"
    Environment = var.env
    Service     = var.service
    Role        = var.role
  }
}