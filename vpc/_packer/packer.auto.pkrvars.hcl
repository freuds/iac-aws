os_family         = "linux"
os_name           = "amazonlinux" #"ubuntu"
os_version        = "2023" #"22.04"
#
role             = "server"
service          = "bastion"
inventory_groups = "bastion"
playbook_file    = "../../_tools/ansible/playbooks/bastion.yml"

# find values on the output of build service's
aws_security_group_filter = "sg-packer"
aws_subnet_name           = "subnet-0ec6b6082145e87ae"
aws_vpc_name              = "build-vpc"
aws_kms_key_id            = "arn:aws:kms:eu-west-1:123456789012:key/alias/packer-key"

# Packer variables for apple M1
# Doc: https://gist.github.com/nrjdalal/e70249bb5d2e9d844cc203fd11f74c55
# qemu_binary = "qemu-system-aarch64"
# accelerator = "hvf"
# machine_type = "virt"
# cpu_type = "cortex-a72"

project_name = "iac-aws"
project_ci = "https://github.com/freuds/iac-aws.git"
project_git = "https://github.com/freuds/iac-aws.git"
project_owner = "fred"
