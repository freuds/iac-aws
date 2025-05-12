#--------------------------------------
# Amazon EBS
#--------------------------------------
source "amazon-ebs" "ubuntu-2204" {
  source_ami_filter {
    filters = {
      name         = "*ubuntu-jammy-22.04-amd64-server*"
      architecture = "x86_64"
    }
    owners = ["099720109477"]
    most_recent = true
  }

  ami_name        = format("ubuntu-2204-%s-%s-%s", var.service, var.role, legacy_isotime("2006-01-02T15-04-05"))
  ami_description = format("ubuntu-%s-%s", var.service, var.role)

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
    osBase  = "ubuntu-2204"
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
    osBase    = "ubuntu-2204"
  }
}

#--------------------------------------
# Vagrant
#--------------------------------------
source "vagrant" "ubuntu-2204" {
  source_path     = "ubuntu/jammy64"
  template        = "${path.root}/../../packer/linux/ubuntu/templates/ubuntu/2204/Vagrantfile.tpl"
  provider        = "virtualbox"
  teardown_method = "suspend"
  skip_package    = true
  communicator    = "ssh"
  box_name        = "ubuntu-2204"
  ssh_username    = "vagrant"
  output_dir      = "${var.build_directory}/ubuntu-2204/vagrant"
}

#--------------------------------------
# Docker
#--------------------------------------
source "docker" "ubuntu-2204" {
  image   = "ubuntu:22.04"
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
    "source.docker.ubuntu-2204",
    "source.vagrant.ubuntu-2204",
    "source.amazon-ebs.ubuntu-2204"
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
    # [ var.inventory_groups ]
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
  #   playbook_file = "../../ansible/galaxy/roles/UBUNTU22-CIS/site.yml"
  #   only          = ["vagrant.ubuntu-2204", "azure-arm.ubuntu-2204", "googlecompute.ubuntu-2204"]
  # }

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
  #   only          = ["amazon-ebs.ubuntu-2204"]
  # }

  provisioner "shell-local" {
    inline = ["curl -s https://api.ipify.org/?format=none"]
  }

  # provisioner "shell" {
  #   execute_command = "chmod +x {{ .Path }}; {{ .Vars }} sudo -E sh '{{ .Path }}'"
  #   inline          = ["/usr/sbin/waagent -force -deprovision+user && export HISTSIZE=0 && sync"]
  #   inline_shebang  = "/bin/sh -x"
  #   only            = ["azure-arm.ubuntu-2204"]
  # }

  # post-processor "docker-tag" {
  #   // repository = "${var.repository}/jenkins"
  #   repository = "jenkins"
  #   tags       = ["${var.version}"]
  # }
}

