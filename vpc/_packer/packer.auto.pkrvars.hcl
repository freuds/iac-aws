template         = "debian-buster"
role             = "server"
service          = "bastion"
inventory_groups = "bastion"
playbook_file    = "../../_tools/ansible/playbooks/bastion.yml"

# find values on the output of build service's
security_group_id = "sg-03d5dc3021dc5a33e"
subnet_id         = "subnet-0903fcf1b43dd444d"
vpc_id            = "vpc-01243526962b57cd6"