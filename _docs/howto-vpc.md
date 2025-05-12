# VPC

We create a VPC-build (VPC+subnet) to create and manage AMIs build from packer.

Also we create a custom VPC for the application and these sub-resources.

- 1 public subnet per AZ
- 1 private subnet per AZ
- 1 Internet Gateway
- 1 Route Table public

## Nat Gateway

You can configure one single NAT or multi-NAT (one NAT by subnet)
By default, one single NAT is defined for all AZs. If you activate it, that build one NAT Gateway on each AZs.

Inside file __vpc/_terraform/variables.tf__ , the variable __one_nat_gateway_per_az__ can change that. Of course, the variable can be overload per env in the __terraform.auto.tfvars__ file
