# IAC AWS

## VPC

Create custom VPC and 2 public subnet and 2 private subnet

### Multi NAT

- build one NAT Gateway on all AZs defined

### Single NAT

- build only one NAT Gateway for one subnet

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
