#--------------------------------------
# Amazon EBS
#--------------------------------------
source "amazon-ebs" "amazonlinux-2023" {
  source_ami_filter {
    filters = {
      name         = "al2023-ami-2023*"
      architecture = "x86_64"
    }
    owners = ["099720109477"]
    most_recent = true
  }

  ami_name        = format("amazonlinux-2023-%s-%s-%s", var.service, var.role, legacy_isotime("2006-01-02T15-04-05"))
  ami_description = format("amazonlinux-2023-%s-%s", var.service, var.role)

  encrypt_boot          = true
  force_delete_snapshot = true
  force_deregister      = true
  kms_key_id            = var.aws_kms_key_id

  region        = var.aws_region
  instance_type = var.aws_instance_type
  ssh_username  = "ec2-user"

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
    osBase  = "amazonlinux-2023"
  }

  tags = {
    Project   = var.project_name
    Env       = var.project_env
    Name      = format("%s-%s", var.service, var.role)
    Role      = var.role
    Service   = var.service
    ci        = var.project_ci
    git       = var.project_git
    owner     = var.project_owner
    osBase    = "amazonlinux-2023"
  }
}

#--------------------------------------
# Vagrant
#--------------------------------------
source "vagrant" "amazonlinux-2023" {
  source_path     = "bento/amazonlinux-2023"
  template        = "${path.root}/../../packer/linux/ubuntu/templates/amazonlinux-2023/Vagrantfile.tpl"
  provider        = "virtualbox"
  teardown_method = "suspend"
  skip_package    = true
  communicator    = "ssh"
  box_name        = "amazonlinux-2023"
  ssh_username    = "vagrant"
  output_dir      = "${var.build_directory}/amazonlinux-2023/vagrant"
}

#--------------------------------------
# Docker
#--------------------------------------
source "docker" "amazonlinux-2023" {
  image   = "amazonlinux:2023"
  commit     = true
  privileged = true
  tmpfs      = ["/run"]
  volumes = {
    "/sys/fs/cgroup/" : "/sys/fs/cgroup:ro"
  }
  changes = [
    "ENTRYPOINT /lib/systemd/systemd"
  ]
}

# a build block invokes sources and runs provisioning steps on them. The
# documentation for build blocks can be found here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/build
build {
  sources = [
    "source.docker.amazonlinux-2023",
    "source.vagrant.amazonlinux-2023",
    "source.amazon-ebs.amazonlinux-2023"
  ]

  provisioner "shell" {
    inline = ["sleep 20"]
    only   = ["amazon-ebs"]
  }

  provisioner "shell" {
    scripts = [
      "${path.root}/../scripts/bootstrap.sh"
    ]
  }

  provisioner "ansible-local" {
    playbook_file   = var.playbook_file
    playbook_dir    = "${path.root}/../../ansible"
    group_vars = "${path.root}/../../ansible/playbooks/group_vars"
    role_paths = [
      "${path.root}/../../ansible/roles",
      "${path.root}/../../ansible/galaxy/roles"
    ]
    inventory_groups = [
      var.inventory_groups
    ]
    extra_arguments = [
      "-vvv",
      "--extra-vars", "\"SERVICE=${var.service}\""
    ]
  }

  # provisioner "ansible" {
  #   command = "./scripts/ansible.sh"
  #   user    = "${build.User}"
  #   extra_arguments = [
  #     #"-v",
  #     "--extra-vars", "foo=bar"
  #   ]
  #   ansible_ssh_extra_args = [
  #     "-o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedKeyTypes=+ssh-rsa"
  #   ]
  #   host_alias    = "none"
  #   playbook_file = "../../ansible/galaxy/roles/AMAZON2023-CIS/site.yml"
  #   only          = ["vagrant.ubuntu-2204", "azure-arm.ubuntu-2204", "googlecompute.ubuntu-2204"]
  # }

  provisioner "shell-local" {
    inline = ["curl -s https://api.ipify.org/?format=none"]
  }

  # post-processor "docker-tag" {
  #   // repository = "${var.repository}/jenkins"
  #   tags       = [
  #     join("-", var.service, var.os_version)
  #   ]
  #   only          = ["docker.amazonlinux-2023"]
  # }
}
