variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "Globally unique S3 bucket name for the static site. If empty, auto-generates as 'static-site-{aws_account_id}-{region}'. Provide via TF_VAR_bucket_name or terraform.tfvars"
  type        = string
  default     = ""
}

variable "auto_generate_bucket_name" {
  description = "If true and bucket_name is empty, auto-generate bucket name"
  type        = bool
  default     = true
}

data "aws_caller_identity" "current" {}

locals {
  bucket_name = var.bucket_name != "" ? var.bucket_name : (
    var.auto_generate_bucket_name ? "static-site-${data.aws_caller_identity.current.account_id}-${var.aws_region}" : ""
  )
}
