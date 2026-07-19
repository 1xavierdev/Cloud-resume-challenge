output "state_bucket_name" {
  value = aws_s3_bucket.tfstate.id
}

output "lock_table_name" {
  value = aws_dynamodb_table.tf_locks.name
}

output "github_actions_role_arn" {
  value       = aws_iam_role.github_actions_ci.arn
  description = "Put this in the repo's Actions variables as AWS_CI_ROLE_ARN — not a secret (it's not a credential), but keeping it out of committed files avoids leaking the account ID into a public repo."
}
