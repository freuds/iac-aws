# Terraform Documentation

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| aws | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| aws | 5.97.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| access\_log | ../../../_tools/terraform/modules/terraform-aws-s3-bucket | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.access_log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| bucket\_prefix | Prefix for current bucket | `string` | `"logs"` | no |
| bucket\_tags | A mapping of tags to assign to the bucket. | `map(string)` | `{}` | no |
| elb\_account\_id | List of ID account for loadbalancer per region (region: account\_id) | `map(string)` | `{}` | no |
| env | n/a | `string` | `"qa"` | no |
| lifecycle\_rules | List of lifecycle rules | `any` | `[]` | no |
| org\_prefix | n/a | `string` | `"fred-iac"` | no |
| region | n/a | `string` | `"eu-west-1"` | no |
| versioning | Define the block for default versioning\_configuration of the bucket | `map(string)` | `{}` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->