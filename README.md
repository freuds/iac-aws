# IAC AWS

This repository manage the following infrastructure on AWS:

- Build VPC / subnets on single or multi-region
- Build a Nat Gateway or HA-Nat Gateway
- Build a Bastion EC2 with packer
- Build a complete EKS
- Build a Vault on EC2.

## Requirements

- terraform
- jq
- git
- curl
- helm
- [terraform-docs](https://github.com/terraform-docs/)
- tfenv
- python3
- [uv](https://docs.astral.sh/uv/)

## Terraform Cloud configuration

Read the [documentation](./_docs/howto-terraform-cloud.md).

## Terraform Version

Define your current version of Terraform in __./.terraform-version__
And use the following command to uniformize the terraform version for all existing services.

```shell
task init:tf:check
```

## Taskfiles (Go-task)

We use here the [go-task](https://taskfile.dev/) for wrap all commands (terraform, jq, helm, and scripts)
A global file at the root of the project : __./TaskFile.yml__
All tasks are defined in the subfolder: __\_tools/taskfiles/*.yml__.

## Services

## Terraform Cloud usage

## SSH to bastion

1. create a new key pair on [AWS Console](https://eu-west-1.console.aws.amazon.com/ec2/v2/home?region=eu-west-1#KeyPairs:) and use 'iac-aws-key' like key name

Host : bastion.qa.<project_name>.domain.com
Username : admin

## Tree Structure for tools/libraries

```txt
_tools
├── ansible
│   ├── playbooks
│   │   ├── group_vars
│   │   └── inventory
│   └── roles
├── packer
│   ├── scripts
│   └── templates
├── scripts
└── terraform
    └── modules
        └── terraform-aws-vpc
```

## Minimum structure for one service

```txt
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
```

## Packer and AMIs building

For some services, inside __packer__ folder, you can build AMIs from different ISO based OS (Debian / CentOS).

```shell
# Validate or inspect
./packer.sh validate
./pacher.sh inspect

# With argument, we build a AMI on AWS
./packer.sh <-debug>

# With argument -local
./pacher.sh -local <qemu> -debug

```shell
Provisioning is done with Ansible.
```

## Usage

> At first for using a new service, we need to initialise terraform, to generate needed links for terraform then use :

```shell
make init
```

after that, you can launch a plan

```shell
make plan
make apply
# or make apply-force
```
