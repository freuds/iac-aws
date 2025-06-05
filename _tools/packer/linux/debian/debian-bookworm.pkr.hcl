#--------------------------------------
# Amazon EBS
#--------------------------------------
source "amazon-ebs" "debian-bookworm" {
  source_ami_filter {
    filters = {
      name         = "debian-12-amd64*"
      architecture = "x86_64"
    }
    owners = ["099720109477"]
    most_recent = true
  }

  ami_name        = format("debian-bookworm-%s-%s-%s", var.service, var.role, legacy_isotime("2006-01-02T15-04-05"))
  ami_description = format("debian-%s-%s", var.service, var.role)

  encrypt_boot          = true
  force_delete_snapshot = true
  force_deregister      = true
  kms_key_id            = var.aws_kms_key_id

  region        = var.aws_region
  instance_type = var.aws_instance_type
  ssh_username  = "debian"

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
    osBase  = "debian-bookworm"
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
    osBase    = "debian-bookworm"
  }
}

#--------------------------------------
# Vagrant
#--------------------------------------
source "vagrant" "debian-bookworm" {
  source_path     = "debian/jammy64"
  template        = "linux/debian/templates/debian/bookworm/Vagrantfile.tpl"
  provider        = "virtualbox"
  teardown_method = "suspend"
  skip_package    = true
  communicator    = "ssh"
  box_name        = "debian-2204"
  output_dir      = "${var.build_directory}/debian-2204/vagrant"
}

#--------------------------------------
# Docker
#--------------------------------------
source "docker" "debian-bookworm" {
  image   = "debian:bookworm"
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
    "source.docker.debian-bookworm",
    "source.vagrant.debian-bookworm",
    "source.amazon-ebs.debian-bookworm"
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
  #   playbook_file = "../../ansible/galaxy/roles/UBUNTU22-CIS/site.yml"
  #   only          = ["vagrant.ubuntu-2204", "azure-arm.ubuntu-2204", "googlecompute.ubuntu-2204"]
  # }

  provisioner "ansible-local" {
    playbook_file   = var.playbook_file
    playbook_dir    = "${path.root}/../../ansible"
    group_vars = "${path.root}/../../ansible/playbooks/group_vars"
    inventory_groups = [var.inventory_groups]
    role_paths = [
      "${path.root}/../../ansible/roles",
      "${path.root}/../../ansible/galaxy/roles"
    ]
    # [ var.inventory_groups ]
    extra_arguments = [
      "-vvv",
      "--extra-vars", "\"SERVICE=${var.service}\""
    ]
    // extra_arguments = ["-vvvv", "--extra-vars", "\"jenkins_version=${var.jenkins_version}\""]
  }


  # post-processor "docker-tag" {
  #   // repository = "${var.repository}/jenkins"
  #   repository = "jenkins"
  #   tags       = ["${var.version}"]
  #   only          = ["docker.debian-2204", "azure-arm.ubuntu-2204", "googlecompute.ubuntu-2204"]
  # }
}

