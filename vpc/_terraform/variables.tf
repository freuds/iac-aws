variable "env" {
  type = string
  default = ""
}

variable "region" {
  type = string
  default = "eu-west-1"
}

variable "cidr_block" {}
variable "subnet_priv_bits" {}
variable "subnet_pub_bits" {}
variable "subnet_pub_offset" {}
variable "internal_domain_name" {}
variable "external_domain_name" {}

variable "eks_public_subnet_tags" {
  default = {}
}

variable "eks_private_subnet_tags" {
  default = {}
}

variable "bastion_ami" {
  default = "ami-2547a34c"
}

variable "bastion_instance_type" {
  default = "t3.micro"
}
variable "bastion_asg_desired_capacity" {
  type    = number
  default = 1
}
variable "bastion_asg_min_size" {
  type    = number
  default = 1
}
variable "bastion_asg_max_size" {
  type    = number
  default = 1
}

variable "db_name" {
  type    = string
  default = "phenix"
}

variable "id_phenix_pub" {
  type    = string
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDpy0vih7TbsOjydGPPcvpoH7SGkKfEcjUTLE1grX6M+JHp1B3FsPaQsRmE07/1k7klO36zsxuXU/MFDs4ycQneaVtAW3ESsLyq8Va4z09CsBKgpL9E9iUpEgxpTOftp5kTYk2NwT8Ujo3Px+Ps1R4lXSW5ECSRlkcWAiSgaqdkoSkhNm2d8/MLtBnt0tT4Uvl+EkKGPERBe77rVHT96IB+MaO2l6Yq0BqhNl8bbPVgSi7cR5tPz+4NJ/YLtAkz2nBhH5y7omies3TnLL1GPqTRrDBvuPxhV+z0TnoJ2FktmgMkwzfRzRdhgdb9p6nMkU4sdjM1/FVQe9tiKlTRevqKhwXkKuxiYHAUxB0NmvJVSx918p+6UU0XX124veif3BvaTMGJteiRAc/bBr6cwyTps6+CpFucaFb5Jrg2Z0WDU6JtpnRZ/9w43bKh+554BiyEZuSa71Pid+uIytjUEpVD1Y+IBwb6G5h2z3DCRdfeQ+ONdQ+wHIcbpcPSc6hV+Q8= rida@Rida"
}

variable "id_phenix_priv" {
  type    = string
  default = <<EOF
-----BEGIN OPENSSH PRIVATE KEY-----
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
0ypjlVp7CMCsUPAAAACXJpZGFAUmlkYQE=
-----END OPENSSH PRIVATE KEY-----
EOF
}


# variable "DATADOG_API_KEY" {
#   description = "Datadog API KEY is defined on TFCLOUD environment variables"
# }

# variable "datadog_agent_enabled" {
#   description = "Enable or not the datadog agent"
#   default     = false
# }
