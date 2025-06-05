<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| gandi | 2.3.0 |

## Providers

| Name | Version |
|------|---------|
| gandi | 2.3.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [gandi_livedns_record.record](https://registry.terraform.io/providers/go-gandi/gandi/2.3.0/docs/resources/livedns_record) | resource |
| [gandi_domain.origin](https://registry.terraform.io/providers/go-gandi/gandi/2.3.0/docs/data-sources/domain) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| gandi\_alias\_ns | Alias Name for NS records | `string` | `""` | no |
| gandi\_aws\_ns | AWS API Route53 for delegation domain | `list(string)` | `[]` | no |
| gandi\_domain\_name | Domain Name | `string` | `"domain.com"` | no |
| gandi\_personal\_access\_token | Gandi PAT (Personal Access Token) defined in Terraform Cloud environment. | `string` | n/a | yes |
| ns\_ttl | n/a | `number` | `3600` | no |

## Outputs

| Name | Description |
|------|-------------|
| gandi\_domain\_name | n/a |
<!-- END_TF_DOCS -->