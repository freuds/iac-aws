# IAC AWS

## VPC

Create custom VPC 
- 1 public subnet per AZ
- 1 private subnet per AZ
- 1 Internet Gateway
- 1 Route Table public

> HA Mode : Multi NAT or Single NAT

variable __one_nat_gateway_per_az__ , disabled by default (false), can found in vpc/_terraform/variables.tf

- build one NAT Gateway on each AZs defined
- build only one NAT Gateway for all AZs subnet

## Terraform Cloud uage
## Tree Structure for tools/libraries

```
_tools
├── ansible
│   ├── playbooks
│   │   ├── group_vars
│   │   └── inventory
│   └── roles
├── packer
│   ├── scripts
│   └── templates
├── scripts
└── terraform
    └── modules
        └── terraform-aws-vpc
```

## Tree structure for services

vpc
├── qa
│   ├── eu-west-1
│   │   ├── override.tf
│   │   ├── Makefile
│   │   ├── terraform.auto.tfvars
│   └── us-east-1
│       ├── override.tf
│       ├── Makefile
│       ├── terraform.auto.tfvars
└── _terraform
    ├── outputs.tf
    ├── main.tf
    ├── variables.tf
    ├── backend.tf
    ├── remote-states.tf
    └── provider.tf
