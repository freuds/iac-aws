cidr_block            = "10.152.0.0/16"
env                   = "qa"
region                = "us-east-1"
subnet_priv_bits      = 4
subnet_pub_bits       = 6
subnet_pub_offset     = 32
internal_domain_name  = "qa.wearephenix.internal"
external_domain_name  = "qa.wearephenix.com"
bastion_ami           = "ami-03d4ce558fcf83f5b"
datadog_agent_enabled = false
eks_private_subnet_tags = {
  "kubernetes.io/cluster/qa-eks-cluster" = "shared"
  "kubernetes.io/role/internal-elb"      = "1"
}
eks_public_subnet_tags = {
  "kubernetes.io/cluster/qa-eks-cluster" = "shared"
  "kubernetes.io/role/elb"               = "1"
}
