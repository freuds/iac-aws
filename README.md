# IAC AWS

## Services

### VPC networking

We create a VPC-build (VPC+subnet) to create and manage AMIs build from packer.

Also we create a custom VPC for the application and these sub-resources.
- 1 public subnet per AZ
- 1 private subnet per AZ
- 1 Internet Gateway
- 1 Route Table public

### Nat Gateway

You can configure one single NAT or multi-NAT (one NAT by subnet)
By default, one single NAT is defined for all AZs. If you activate it, that build one NAT Gateway on each AZs.

Inside file __vpc/_terraform/variables.tf__ , the variable __one_nat_gateway_per_az__ can change that. Of course, the variable can be overload per env in the __terraform.auto.tfvars__ file

## Terraform Cloud usage

## SSH to bastion

1. create a new key pair on [AWS Console](https://eu-west-1.console.aws.amazon.com/ec2/v2/home?region=eu-west-1#KeyPairs:) and use 'iac-aws-key' like key name

2. 

Host : bastion.qa.<project_name>.domain.com
Username : admin


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

## Minimum structure for one service

```
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
```
# Validate or inspect
./packer.sh validate
./pacher.sh inspect

# With argument, we build a AMI on AWS
./packer.sh <-debug>

# With argument -local 
./pacher.sh -local <qemu> -debug
```
Provisioning is done with Ansible.

## Usage

> At first for using a new service, we need to initialise terraform, to generate needed links for terraform then use :
```
make init
```

after that, you can launch a plan
```
make plan
make apply
# or make apply-force 
```

## TODO

- [X] : Implement module gandi-dns : up to date AWS NS inside Gandi Zone
- [ ] : Secure (SSH) instances : modify SG, ssh_port, and packer build 
- [X] : bastion module : rewrite role_policy
- [X] : bastion module : fix ipaddress re-assign
- [ ] : bastion module : add KMS encryption
