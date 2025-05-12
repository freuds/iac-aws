#--------------------------------------
# Amazon EBS
#--------------------------------------
source "amazon-ebs" "ubuntu-2004" {
  source_ami_filter {
    filters = {
      name         = "*ubuntu-focal-20.04-amd64-server*"
      architecture = "x86_64"
    }
    owners = ["099720109477"]
    most_recent = true
  }
  ami_name        = format("ubuntu-2004-%s-%s-%s", var.service, var.role, legacy_isotime("2006-01-02T15-04-05"))
  ami_description = format("debian-%s-%s", var.service, var.role)

  encrypt_boot          = true
  force_delete_snapshot = true
  force_deregister      = true
  kms_key_id            = var.aws_kms_key_id

  region        = var.aws_region
  instance_type = var.aws_instance_type
  ssh_username  = "ubuntu"

  vpc_filter {
    filters = {
      "tag:Name" = var.aws_vpc_name
    }
  }
  subnet_filter {
    filters = {
      "tag:Name" = var.aws_subnet_name
    }
    most_free = true
    random    = true
  }

  security_group_filter {
    filters = {
      "tag:Name" : var.aws_security_group_filter
    }
  }

  run_tags = {
    Project = var.project_name
    Env     = var.project_env
    Name    = format("Packer Builder %s", var.service)
    ci      = var.project_ci
    git     = var.project_git
    owner   = var.project_owner
    osBase  = "ubuntu-2004"
  }

  tags = {
    Project   = var.project_name
    Env       = var.project_env
    Name      = format("%s-%s", var.service, var.role)
    Role      = var.role
    Service   = var.service
    SourceAMI = var.source_ami
    ci        = var.project_ci
    git       = var.project_git
    owner     = var.project_owner
    osBase    = "ubuntu-2004"
  }
}

#--------------------------------------
# Vagrant
#--------------------------------------
source "vagrant" "ubuntu-2004" {
  source_path     = "ubuntu/focal64"
  template        = "linux/ubuntu/templates/ubuntu/2004/Vagrantfile.tpl"
  provider        = "virtualbox"
  teardown_method = "suspend"
  skip_package    = true
  communicator    = "ssh"
  box_name        = "ubuntu-2004"
  output_dir      = "${var.build_directory}/ubuntu-2004/vagrant"
}

#--------------------------------------
# Docker
#--------------------------------------
source "docker" "ubuntu-2004" {
  image   = "ubuntu:20.04"
  commit  = false
  discard = true
}

# a build block invokes sources and runs provisioning steps on them. The
# documentation for build blocks can be found here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/build
build {
  sources = [
    "source.docker.ubuntu-2004",
    "source.vagrant.ubuntu-2004",
    "source.amazon-ebs.ubuntu-2004",
  ]

  provisioner "shell" {
    inline = ["cat /etc/os-release"]
  }

  provisioner "shell-local" {
    inline = ["curl -s https://api.ipify.org/?format=none"]
  }
}

