# Documentation

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_internet_gateway.gw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_route_table.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.rtap](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_security_group.packer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_subnet.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.build](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_vpc_endpoint.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint_route_table_association.s3-rt-public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint_route_table_association) | resource |
| [aws_vpc_endpoint_service.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc_endpoint_service) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| azs | n/a | `map(list(string))` | <pre>{<br/>  "eu-west-1": [<br/>    "eu-west-1a"<br/>  ]<br/>}</pre> | no |
| cidr\_block | n/a | `string` | `"10.110.0.0/20"` | no |
| enable\_dns\_hostnames | n/a | `bool` | `true` | no |
| enable\_dns\_support | n/a | `bool` | `true` | no |
| region | n/a | `string` | `"eu-west-1"` | no |
| s3\_endpoint\_enabled | n/a | `bool` | `false` | no |
| ssh\_port | n/a | `number` | `22` | no |
| subnet\_bits | n/a | `number` | `4` | no |
| trusted\_networks | n/a | `list(string)` | <pre>[<br/>  "0.0.0.0/0"<br/>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| public\_subnets | n/a |
| security\_group\_public\_subnet | n/a |
| vpc\_id | n/a |
<!-- END_TF_DOCS -->