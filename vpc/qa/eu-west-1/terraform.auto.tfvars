cidr_block           = "10.152.0.0/16"
env                  = "qa"
region               = "eu-west-1"
subnet_priv_bits     = 4
subnet_pub_bits      = 6
subnet_pub_offset    = 32
internal_domain_name = "qa.iac.internal"
external_domain_name = "qa.iac.freuds.me"

one_nat_gateway_per_az = false

bastion_ami  = "ami-08ff4525d1ad50904"
root_keypair = "iac-aws-key"

gandi_domain_name = "freuds.me"
gandi_alias_ns    = "qa.iac"

bastion_enabled = false
ssh_port = 2345

# subnet_priv_tags = {
#   "kubernetes.io/cluster/qa-eks-cluster" = "shared"
#   "kubernetes.io/role/internal-elb"      = "1"
# }
# subnet_pub_tags = {
#   "kubernetes.io/cluster/qa-eks-cluster" = "shared"
#   "kubernetes.io/role/elb"               = "1"
# }
