# Documentation

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| aws | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_s3_bucket.encrypted_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_lifecycle_configuration.lifecycle](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_ownership_controls.object_ownership](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) | resource |
| [aws_s3_bucket_policy.policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.encryption](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.versioning](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_iam_policy_document.bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| aes | Use AES encryption instead of KMS | `bool` | `false` | no |
| bucket\_name | Name of the S3 bucket | `any` | n/a | yes |
| bucket\_tags | The tags of the S3 bucket | `map(string)` | `{}` | no |
| environment | Environment name | `string` | n/a | yes |
| extra\_policy | policy document to add to bucket policy | `string` | `""` | no |
| force\_destroy | A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable. | `bool` | `false` | no |
| force\_encrypted\_uploads | Set a bucket policy blocking non-encrypted uploads. | `bool` | `false` | no |
| lifecycle\_rules | List of lifecycle rules | `any` | `[]` | no |
| mfa\_delete | Enable MFA delete for either Change the versioning state of your bucket or Permanently delete an object version. Default is false. | `bool` | `false` | no |
| object\_ownership | Object ownership rule for objects uploaded to the bucket from the same account or another one | `string` | `"BucketOwnerEnforced"` | no |
| replicating\_shore | Indicates if we are replicating a shore bucket | `bool` | `false` | no |
| replication\_dest\_bucket\_arn | S3 bucket arn in which objects will be replicated | `string` | `""` | no |
| replication\_exclude\_prefixes | List of shores that will not be replicated in a cross-region bucket | `any` | `[]` | no |
| replication\_iam\_role\_arn | IAM role arn assumed by S3 to replicate data | `string` | `""` | no |
| replication\_kms\_key\_id | KMS Key ID used to encrypt replicated S3 objects | `string` | `""` | no |
| replication\_prefixes | List of S3 prefixes to replicate | `any` | `[]` | no |
| set\_replication | Set objects replication or not | `bool` | `false` | no |
| versioning | Define the block for default versioning\_configuration of the bucket | `map(string)` | <pre>{<br/>  "mfa_delete": false,<br/>  "status": true<br/>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| bucket\_arn | n/a |
| bucket\_domain\_name | n/a |
| bucket\_id | n/a |
| bucket\_regional\_domain\_name | n/a |
<!-- END_TF_DOCS -->