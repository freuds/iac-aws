cidr_block           = "10.152.0.0/16"
env                  = "qa"
region               = "eu-west-1"
subnet_priv_bits     = 4
subnet_pub_bits      = 6
subnet_pub_offset    = 32
internal_domain_name = "qa.iac.internal"
external_domain_name = "qa.iac.freuds.fr"

one_nat_gateway_per_az = false

# AWS AMI  Linux 2 (64 bit x86) : ami-02b4e72b17337d6c1
# AWS AMI  Linux 2 (64 bit Arm) : ami-04b149cd223547c24
bastion_ami  = "ami-02b4e72b17337d6c1"
root_keypair = "iac-aws-key"

# Gandi
gandi_domain_name = "freuds.fr"
gandi_alias_ns    = "qa.iac"
# Set in TFC : TF_VAR_gandi_apikey

bastion_enabled = false
ssh_port        = 2345
