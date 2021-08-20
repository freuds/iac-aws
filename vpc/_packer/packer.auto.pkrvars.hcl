template         = "debian-buster"
role             = "server"
service          = "bastion"
inventory_groups = "bastion"
playbook_file    = "../../_tools/ansible/playbooks/bastion.yml"

# find values on the output of build service's
security_group_id = "sg-09856bd9e33b68d63"
subnet_id         = "subnet-0b0bb84a0e4ee3d5f"
vpc_id            = "vpc-015a9f3d3f5b52f4b"

# Packer variables for apple M1
# Doc: https://gist.github.com/nrjdalal/e70249bb5d2e9d844cc203fd11f74c55
qemu_binary = "qemu-system-aarch64"
accelerator = "hvf"
machine_type = "virt"
cpu_type = "cortex-a72"

PROJECT_NAME = "iac-aws"
PROJECT_CI = "https://github.com/freuds/iac-aws.git"
PROJECT_GIT = "https://github.com/freuds/iac-aws.git"
PROJECT_OWNER = "fred"
