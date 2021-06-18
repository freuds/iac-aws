template         = "debian-buster"
role             = "server"
service          = "bastion"
inventory_groups = "bastion"
playbook_file    = "../../_tools/ansible/playbooks/bastion.yml"

# find values on the output of build service's
security_group_id = "sg-03d5dc3021dc5a33e"
subnet_id         = "subnet-0903fcf1b43dd444d"
vpc_id            = "vpc-01243526962b57cd6"

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
