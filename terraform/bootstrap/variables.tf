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

# GitHub's OIDC tokens embed the owner's and repo's immutable numeric IDs in
# the `sub` claim alongside their names (format:
# repo:OWNER@OWNER_ID/REPO@REPO_ID:ref:refs/heads/BRANCH) rather than just
# `repo:OWNER/REPO:ref:...` — confirmed by decoding an actual issued token
# during troubleshooting (2026-07-19). This survives repo renames/transfers,
# which is presumably why GitHub moved to it, but it means the trust policy
# has to match on IDs, not just names. Find these via the GitHub API:
# `curl -s https://api.github.com/repos/OWNER/REPO | jq '.owner.id, .id'`
variable "github_owner_id" {
  description = "Numeric GitHub user/org ID for github_repo's owner (part of the OIDC sub claim)."
  type        = string
  default     = "118237090"
}

variable "github_repo_id" {
  description = "Numeric GitHub repository ID for github_repo (part of the OIDC sub claim)."
  type        = string
  default     = "1301903149"
}
