# IAC AWS


## Tree Structure for tools/libraries

```
_tools
├── ansible
│   ├── playbooks
│   │   ├── group_vars
│   │   └── inventory
│   └── roles
│       ├── apt
│       ├── attach-eip
│       ├── authorized-keys
│       ├── aws-cli
│       ├── datadog
│       ├── dehydrated
│       ├── gomplate
│       ├── haproxy
│       ├── haproxy-ingress
│       └── helm-cli
├── packer
│   ├── scripts
│   └── templates
├── scripts
└── terraform
    └── modules
        ├── terraform-aws-bastion
        ├── terraform-aws-bootstrap
        ├── terraform-aws-packer-build
        └── terraform-aws-vpc
```


## Tree structure for services
- _tools

- service/environment/region
