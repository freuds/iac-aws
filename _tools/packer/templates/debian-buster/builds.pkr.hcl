packer {
  required_plugins {
    amazon = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/amazon"
    }
    qemu = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

# documentation for build blocks can be found here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/build
build {

  sources = [
    "source.amazon-ebs.source"
  ]
  // sources = ["source.amazon-ebs.debian", "source.qemu.ubuntu"]
  // sources = ["source.qemu.debian"]


  provisioner "shell" {
    inline = ["sleep 20"]
    only   = ["amazon-ebs"]
  }

  provisioner "shell" {
    scripts = ["${path.root}/../../scripts/bootstrap.sh"]
  }

  provisioner "ansible-local" {
    extra_arguments  = ["--extra-vars \"SERVICE=${var.service}\"", "-e ansible_python_interpreter=/usr/bin/python3"]
    group_vars       = "${path.root}/../../../ansible/playbooks/group_vars"
    inventory_groups = ["${var.inventory_groups}"]
    playbook_dir     = "${path.root}/../../../ansible"
    playbook_file    = "${var.playbook_file}"
  }

  provisioner "shell" {
    scripts = ["${path.root}/../../scripts/cleanup.sh"]
  }

}