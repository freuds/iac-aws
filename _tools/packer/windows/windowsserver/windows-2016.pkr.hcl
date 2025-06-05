#--------------------------------------
# Amazon EBS
#--------------------------------------
source "amazon-ebs" "windows-2016" {
  ami_name        = format("windows-2016-%s-%s-%s", var.service, var.role, legacy_isotime("2006-01-02T15-04-05"))
  ami_description = format("debian-%s-%s", var.service, var.role)

  encrypt_boot          = true
  force_delete_snapshot = true
  force_deregister      = true
  kms_key_id            = var.aws_kms_key_id

  region        = var.aws_region
  instance_type = var.aws_instance_type

  user_data_file   = "./windows/windowsserver/scripts/bootstrap.txt"
  communicator     = "winrm"
  winrm_username   = "Administrator"
  winrm_insecure   = true
  winrm_use_ssl    = true
  source_ami_filter {
    filters = {
      name                = "Windows_Server-2016-English-Full-Base*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["801119661308"]
  }

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
    osBase  = "windows-2016"
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
    osBase    = "windows-2016"
  }

}

#--------------------------------------
# Vagrant
#--------------------------------------
source "vagrant" "windows-2016" {
  source_path = "jborean93/WindowsServer2016"
  provider    = "virtualbox"
  # the Vagrant builder currently only supports the ssh communicator
  communicator    = "ssh"
  ssh_username    = "vagrant"
  ssh_password    = "vagrant"
  teardown_method = "suspend"
  skip_package    = true
  box_name        = "windows-2016"
  output_dir      = "${var.build_directory}/windows-2016/vagrant"
}

# a build block invokes sources and runs provisioning steps on them. The
# documentation for build blocks can be found here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/build
build {
  sources = [
    "source.amazon-ebs.windows-2016",
    "source.vagrant.windows-2016"
  ]

  # provisioner "ansible" {
  #   command   = "./scripts/ansible.sh"
  #   user      = "${build.User}"
  #   use_proxy = false
  #   ansible_env_vars = [
  #     "ANSIBLE_HOST_KEY_CHECKING=False",
  #     "ANSIBLE_SSH_ARGS='-o ForwardAgent=yes -o ControlMaster=auto -o ControlPersist=60s -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'",
  #     "ANSIBLE_NOCOLOR=True"
  #   ]
  #   extra_arguments = [
  #     #"-v",
  #     "--extra-vars",
  #     "ansible_ssh_pass=${build.User} version_number=${local.version_number} ansible_shell_type=cmd ansible_shell_executable=None"
  #   ]
  #   host_alias    = "none"
  #   playbook_file = "../../ansible/roles/ansible-role-example-role/site.yml"
  #   only          = ["vagrant.windows-2016"]
  # }

  # provisioner "ansible" {
  #   command   = "./scripts/ansible.sh"
  #   user      = "${build.User}"
  #   use_proxy = false
  #   ansible_env_vars = [
  #     "ANSIBLE_HOST_KEY_CHECKING=False",
  #     "ANSIBLE_SSH_ARGS='-o ForwardAgent=yes -o ControlMaster=auto -o ControlPersist=60s -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'",
  #     "ANSIBLE_NOCOLOR=True"
  #   ]
  #   extra_arguments = [
  #     #"-v",
  #     "--extra-vars",
  #     "ansible_ssh_pass=${build.User} version_number=${local.version_number} ansible_shell_type=cmd ansible_shell_executable=None rule_2_3_1_5=false win_skip_for_test=true rule_2_3_1_1=false"
  #   ]
  #   host_alias    = "none"
  #   playbook_file = "../../ansible/galaxy/roles/Windows-2016-CIS/site.yml"
  #   only          = ["vagrant.windows-2016"]
  # }


  # provisioner "ansible" {
  #   command   = "./packer/scripts/ansible.sh"
  #   user      = "${build.User}"
  #   use_proxy = false
  #   extra_arguments = [
  #     #"-v",
  #     "--extra-vars",
  #     "ansible_winrm_server_cert_validation=ignore ansible_connection=winrm ansible_shell_type=powershell ansible_shell_executable=None ansible_user=${build.User}"
  #   ]
  #   host_alias    = "none"
  #   playbook_file = "../../ansible/roles/ansible-role-example-role/site.yml"
  #   only          = ["amazon-ebs.windows-2016"]
  # }

  # provisioner "ansible" {
  #   command   = "./scripts/ansible.sh"
  #   user      = "${build.User}"
  #   use_proxy = false
  #   extra_arguments = [
  #     #"-v",
  #     "--extra-vars",
  #     "ansible_winrm_server_cert_validation=ignore ansible_connection=winrm ansible_shell_type=powershell ansible_shell_executable=None ansible_user=${build.User} section01_patch=true section02_patch=false section09_patch=true section17_patch=true section18_patch=false section19_patch=false rule_2_3_1_5=false rule_2_3_1_6=false"
  #   ]
  #   host_alias    = "none"
  #   playbook_file = "../../ansible/galaxy/roles/Windows-2016-CIS/site.yml"
  #   only          = ["amazon-ebs.windows-2016"]
  # }

  # provisioner "shell-local" {
  #   inline = ["curl -s https://api.ipify.org/?format=none"]
  # }


  # Install EC2Launch
  provisioner "powershell" {
    inline = [
      "Write-Host \"Download EC2Launch to temp folder $env:Temp\"",
      "Invoke-WebRequest -Uri https://s3.amazonaws.com/ec2-downloads-windows/EC2Launch/latest/EC2-Windows-Launch.zip -OutFile $env:Temp/EC2-Windows-Launch.zip",
      "Invoke-WebRequest -Uri https://s3.amazonaws.com/ec2-downloads-windows/EC2Launch/latest/install.ps1 -OutFile $env:Temp/EC2Launch-Install.ps1",
      "Write-Host Install EC2Launch",
      "Invoke-Expression -Command $env:Temp/EC2Launch-Install.ps1"
    ]
    only = ["amazon-ebs.windows-2016"]
  }

  # Print out EC2Launch Version
  provisioner "powershell" {
    inline = [
      "Write-Host EC2Launch Version",
      "Test-ModuleManifest -Path \"C:\\ProgramData\\Amazon\\EC2-Windows\\Launch\\Module\\Ec2Launch.psd1\""]
      only = ["amazon-ebs.windows-2016"]
  }

  provisioner "powershell" {
    inline = [
      "C:/ProgramData/Amazon/EC2-Windows/Launch/Scripts/InitializeInstance.ps1 -Schedule",
      "C:/ProgramData/Amazon/EC2-Windows/Launch/Scripts/SysprepInstance.ps1 -NoShutdown"
    ]
    only = ["amazon-ebs.windows-2016"]
  }

}
