# IAC AWS

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
│   │   ├── _override.tf
│   │   ├── Makefile
│   │   ├── terraform.auto.tfvars
│   └── us-east-1
│       ├── _override.tf
│       ├── Makefile
│       ├── terraform.auto.tfvars
└── _terraform
    ├── outputs.tf
    ├── main.tf
    ├── variables.tf
    ├── _backend.tf
    ├── remote-states.tf
    └── _provider.tf

- _tools

- service/environment/region
