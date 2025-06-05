# Terraform documentation

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13.0 |
| aws | ~> 5.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| build | ../../../_tools/terraform/modules/terraform-aws-packer-build | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| azs | n/a | `map(list(string))` | <pre>{<br/>  "eu-west-1": [<br/>    "eu-west-1a"<br/>  ]<br/>}</pre> | no |
| cidr\_block | n/a | `string` | `"10.110.0.0/20"` | no |
| env | n/a | `string` | `"admin"` | no |
| region | n/a | `string` | `"eu-west-1"` | no |
| s3\_endpoint\_enabled | n/a | `bool` | `false` | no |
| ssh\_port | n/a | `number` | `22` | no |
| trusted\_networks | n/a | `list(string)` | <pre>[<br/>  "0.0.0.0/0"<br/>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| public\_subnets | n/a |
| security\_group\_public\_subnet | n/a |
| vpc\_id | n/a |
<!-- END_TF_DOCS -->