variable "template" {
  type        = string
  default     = ""
  description = "Folder contains template pkr.hcl files"
}

variable "PROJECT_CI" {
  type    = string
  default = ""
}

variable "PROJECT_ENV" {
  type    = string
  default = "QA"
}

variable "PROJECT_GIT" {
  type    = string
  default = ""
}

variable "PROJECT_NAME" {
  type    = string
  default = ""
}

variable "PROJECT_OWNER" {
  type    = string
  default = ""
}

variable "profile" {
  type    = string
  default = "revolve"
}

variable "box_base_mac" {
  type    = string
  default = "undefined"
}

variable "box_checksum" {
  type    = string
  default = "undefined"
}

variable "box_folder" {
  type    = string
  default = "undefined"
}

variable "box_name" {
  type    = string
  default = "bento/debian-10"
}

variable "box_version" {
  type    = string
  default = "202105.25.0"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "inventory_groups" {
  type = string
}

variable "playbook_file" {
  type = string
}

variable "region" {
  type    = string
  default = "eu-west-1"
}

variable "role" {
  type = string
}

variable "country" {
  default = "FR"
  type = string
}

variable "locale" {
  default = "en_US.UTF-8"
  type = string
}

variable "language" {
  default = "en"
  type = string
}

variable "keyboard" {
  default = "us"
  type = string
}

variable "security_group_id" {
  type    = string
  default = ""
}

variable "service" {
  type = string
}

variable "shared_account" {
  type = list(string)
  default = []
}

variable "source_ami" {
  type    = string
  default = "ami-0874dad5025ca362c"
}

variable "subnet_id" {
  type    = string
  default = ""
}

variable "vagrant_ssh_private_key" {
  type    = string
  default = ""
}

variable "vpc_id" {
  type    = string
  default = ""
}

variable "skip_create_ami" {
  type    = bool
  default = false
}

variable "accelerator" {
  default = "kvm"
  description = "Use KVM for linux host or HVF for MacOS"
}

variable "apt_cache_url" {
  default = "http://myserver:3142"
}

variable "boot_wait" {
  default = "1800s"
}

variable "disk_interface" {
  type = string
  default = "virtio"
}

variable "disk_size" {
  default = "10G"
  type = string
}

variable "domain" {
  default = ""
}

variable "qemu_format" {
  type = string
  default = "qcow2"
  description = "Virtualization format for QEMU"
}

variable "headless" {
  default = true
  type = bool
}

variable "communicator" {
  default = "ssh"
}

variable "cpus" {
  default = 1
  type = number
}

variable "cpu_type" {
  default = ""
}

variable "preseed_file" {
  default = "base-uefi.preseed"
}

variable "host_port_max" {
  type = number
  default = 4444
}

variable "host_port_min" {
  type = number
  default = 2222
}

variable "http_port_max" {
  type = number
  default = 9000
}

variable "http_port_min" {
  type = number
  default = 8000
}

variable "http_directory" {
  default = "../../_tools/packer/templates/debian-buster/http"
}

variable "machine_type" {
  default = "pc"
}

variable "packer_cache_dir" {
  default = "packer_cache"
}

variable "iso_file" {
  default = "debian-10.9.0-amd64-netinst.iso"
  description = "Link to ISO file"
}

variable "iso_checksum" {
  default = "sha512:47d35187b4903e803209959434fb8b65ead3ad2a8f007eef1c3d3284f356ab9955aa7e15e24cb7af6a3859aa66837f5fa2e7441f936496ea447904f7dddfdc20"
}

variable "iso_path_external" {
  default = "http://cdimage.debian.org/cdimage/release/current/amd64/iso-cd"
}

variable "iso_path_internal" {
  default = "http://myserver:8080/debian"
}

variable "memory" {
  default = "768"
  type = number
}

variable "output_directory" {
  default = "packer_cache/build"
}

variable "shutdown_command" {
  default = "echo 'Packer' | sudo shutdown -P now"
}

variable "shutdown_timeout" {
  default = "5m"
}

variable "vm_name" {
  default = "debian10"
}

variable "ssh_agent_auth" {
  default = false
  type = bool
}

variable "ssh_clear_authorized_keys" {
  default = false
  type = bool
}

variable "ssh_disable_agent_forwarding" {
  default = false
  type = bool
}

variable "ssh_file_transfer_method" {
  default = "scp"
}

variable "ssh_keep_alive_interval" {
  default = "5s"
}

variable "ssh_password" {
  default = "ZAtr56gt0uV"
  type = string
  sensitive = true
}

variable "ssh_port" {
  default = 22
  type = number
}

variable "ssh_pty" {
  default = false
  type = bool
}

variable "ssh_timeout" {
  default = "60m"
}

variable "ssh_username" {
  default = "debian"
}

variable "ssh_wait_timeout" {
  default = "120m"
}

variable "qemu_binary" {
  default = "qemu-system-x86_64"
}

variable "vnc_vrdp_bind_address" {
  default = "127.0.0.1"
}

variable "vnc_vrdp_port_max" {
  default = "6000"
}

variable "vnc_vrdp_port_min" {
  default = "5900"
}
