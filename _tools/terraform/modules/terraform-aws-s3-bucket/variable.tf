variable "bucket_name" {
  description = "Name of the S3 bucket"
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "object_ownership" {
  description = "Object ownership rule for objects uploaded to the bucket from the same account or another one"
  default     = "BucketOwnerEnforced"
}

variable "versioning" {
  default = {
    status     = true
    mfa_delete = false
  }
  type        = map(string)
  description = "Define the block for default versioning_configuration of the bucket"
}

variable "bucket_tags" {
  description = "The tags of the S3 bucket"
  default     = {}
  type        = map(string)
}

variable "force_encrypted_uploads" {
  description = "Set a bucket policy blocking non-encrypted uploads."
  default     = false
}

variable "force_destroy" {
  description = "A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable."
  default     = false
}

variable "mfa_delete" {
  description = "Enable MFA delete for either Change the versioning state of your bucket or Permanently delete an object version. Default is false."
  default     = false
}

variable "aes" {
  description = "Use AES encryption instead of KMS"
  default     = false
}

variable "lifecycle_rules" {
  description = "List of lifecycle rules"
  default     = []
  type        = any
}

variable "extra_policy" {
  description = "policy document to add to bucket policy"
  default     = ""
  type        = string
}

variable "set_replication" {
  description = "Set objects replication or not"
  default     = false
  type        = bool
}

variable "replication_iam_role_arn" {
  description = "IAM role arn assumed by S3 to replicate data"
  default     = ""
}

variable "replication_kms_key_id" {
  description = "KMS Key ID used to encrypt replicated S3 objects"
  default     = ""
}

variable "replication_prefixes" {
  description = "List of S3 prefixes to replicate"
  default     = []
  type        = any
}

variable "replication_exclude_prefixes" {
  description = "List of shores that will not be replicated in a cross-region bucket"
  type        = any
  default     = []
}

variable "replication_dest_bucket_arn" {
  description = "S3 bucket arn in which objects will be replicated"
  default     = ""
}

variable "replicating_shore" {
  description = "Indicates if we are replicating a shore bucket"
  default     = false
  type        = bool
}
