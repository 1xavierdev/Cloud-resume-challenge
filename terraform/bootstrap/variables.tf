variable "aws_region" {
  description = "AWS region for the state bucket, lock table, and all resume-* resources."
  type        = string
  default     = "us-east-1"
}

variable "state_bucket_name" {
  description = "S3 bucket that holds the main stack's remote Terraform state."
  type        = string
  default     = "xavier-mckenzie-resume-2026-tfstate"
}

variable "lock_table_name" {
  description = "DynamoDB table used for Terraform state locking on the main stack."
  type        = string
  default     = "resume-terraform-locks"
}

variable "site_bucket_name" {
  description = "The main stack's site bucket name — needed here so the CI role's policy can be scoped to it without a cross-stack data lookup."
  type        = string
  default     = "xavier-mckenzie-resume-2026"
}

variable "github_repo" {
  description = "GitHub repo (owner/name) allowed to assume the CI role, scoped to pushes on main."
  type        = string
  default     = "1xavierdev/Cloud-resume-challenge"
}
