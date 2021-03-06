# source. Read the documentation for source blocks here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/source

//####################################################
// AMAZON-EBS
//####################################################
source "amazon-ebs" "source" {
  ami_description = "debian-${var.service}-${var.role}"
  ami_name        = "${var.service}-${var.role}-${legacy_isotime("2006-01-02T15-04-05")}"
  ami_regions     = ["eu-west-1"]
  // ami_users                   = "${var.shared_account}"
  associate_public_ip_address = true
  instance_type               = var.instance_type
  region                      = var.region
  profile                     = var.profile
  skip_create_ami             = var.skip_create_ami
  source_ami                  = var.source_ami

  run_tags = {
    Appli = var.PROJECT_NAME
    Env   = var.PROJECT_ENV
    Name  = "Packer Builder ${var.service}"
    ci    = var.PROJECT_CI
    git   = var.PROJECT_GIT
    owner = var.PROJECT_OWNER
  }

  security_group_id = var.security_group_id
  ssh_pty           = true
  ssh_username      = "admin"
  subnet_id         = var.subnet_id
  vpc_id            = var.vpc_id

  tags = {
    Appli     = var.PROJECT_NAME
    Env       = var.PROJECT_ENV
    Name      = "${var.service}-${var.role}"
    Role      = var.role
    Service   = var.service
    SourceAMI = var.source_ami
    ci        = var.PROJECT_CI
    git       = var.PROJECT_GIT
    owner     = var.PROJECT_OWNER
  }
}

//####################################################
// QEMU
//####################################################
source "qemu" "source" {
  boot_command      = [
      "<wait><wait><wait>c<wait><wait><wait>",
      "linux /install.amd/vmlinuz ",
      "auto=true ",
      "url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/${var.preseed_file} ",
      "hostname=${var.vm_name} ",
      "domain=${var.domain} ",
      "interface=auto ",
      "vga=788 noprompt quiet --<enter>",
      "initrd=/install/initrd.gz<enter>",
      "boot=<enter>"
  ]
  boot_wait         = var.boot_wait
  communicator      = var.communicator
  cpus              = var.cpus
  disk_size         = var.disk_size
  headless          = var.headless

  disk_interface    = var.disk_interface
  format            = var.qemu_format
  host_port_max     = var.http_port_max
  host_port_min     = var.http_port_min
  http_directory    = var.http_directory
  http_port_max     = var.http_port_max
  http_port_min     = var.http_port_min
  iso_checksum = var.iso_checksum
  iso_target_path      = "${var.packer_cache_dir}/${var.iso_file}"
  iso_urls           = [
    "${var.iso_path_internal}/${var.iso_file}",
    "${var.iso_path_external}/${var.iso_file}"
  ]
  memory = var.memory
  output_directory  = var.output_directory
  shutdown_command  = var.shutdown_command
  shutdown_timeout  = var.shutdown_timeout
  vm_name           = var.vm_name

  ssh_agent_auth               = var.ssh_agent_auth
  ssh_clear_authorized_keys    = var.ssh_clear_authorized_keys
  ssh_disable_agent_forwarding = var.ssh_disable_agent_forwarding
  ssh_file_transfer_method     = var.ssh_file_transfer_method
  ssh_keep_alive_interval      = var.ssh_keep_alive_interval
  ssh_password                 = var.ssh_password
  ssh_port                     = var.ssh_port
  ssh_pty                      = var.ssh_pty
  ssh_timeout                  = var.ssh_timeout
  ssh_username                 = var.ssh_username
  ssh_wait_timeout             = var.ssh_wait_timeout

  accelerator         = var.accelerator
  disk_cache          = "writeback"
  disk_compression    = false
  disk_discard        = "ignore"
  disk_image          = false
  iso_skip_cache      = false
  machine_type        = var.machine_type
  net_device          = "virtio-net"
  qemu_binary         = var.qemu_binary
  skip_compaction     = true
  use_default_display = false
  vnc_bind_address    = var.vnc_vrdp_bind_address
  vnc_port_max        = var.vnc_vrdp_port_max
  vnc_port_min        = var.vnc_vrdp_port_min
  qemuargs            = [
    ["-machine", var.machine_type],
    ["-cpu", var.cpu_type],
    ["-smp", "4"],
    ["-device", "virtio-gpu-pci"],
    ["-device", "virtio-keyboard-pci"],
    ["-m", "4G"]
  ]
}

// source "virtualbox-ovf" "source" {
//   checksum             = var.box_checksum
//   communicator         = "ssh"
//   guest_additions_mode = "disable"
//   headless             = true
//   output_directory     = "/tmp/packer_output"
//   shutdown_command     = "sudo shutdown -P now"
//   skip_export          = true
//   source_path          = "${var.box_folder}/box.ovf"
//   ssh_port             = "62222"
//   ssh_private_key_file = "~/.vagrant.d/insecure_private_key"
//   ssh_pty              = true
//   ssh_skip_nat_mapping = true
//   ssh_username         = "vagrant"
//   ssh_wait_timeout     = "1000s"
//   target_path          = "/tmp/packer_cache"
//   vboxmanage           = [["modifyvm", "{{ .Name }}", "--cpus", "2"], ["modifyvm", "{{ .Name }}", "--memory", "2048"], ["modifyvm", "{{ .Name }}", "--nic1", "nat"], ["modifyvm", "{{ .Name }}", "--natpf1", "packerssh,tcp,127.0.0.1,62222,,22"], ["modifyvm", "{{ .Name }}", "--uart1", "0x3F8", "4"], ["modifyvm", "{{ .Name }}", "--macaddress1", "${var.box_base_mac}"], ["modifyvm", "{{ .Name }}", "--accelerate3d", "off"], ["modifyvm", "{{ .Name }}", "--graphicscontroller", "vmsvga"], ["modifyvm", "{{ .Name }}", "--pae", "off"], ["modifyvm", "{{ .Name }}", "--nestedpaging", "on"], ["modifyvm", "{{ .Name }}", "--vram", "128"]]
// }