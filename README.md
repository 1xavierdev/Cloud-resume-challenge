# Cloud Resume Challenge — Xavier McKenzie

Tracking my build of the [Cloud Resume Challenge](https://cloudresumechallenge.dev/docs/the-challenge/aws/) (AWS, Terraform variant).

## Status: Week 3 complete, IaC caught up

- [x] HTML resume drafted (`index.html`)
- [x] CSS styling (`style.css`)
- [x] AWS account + IAM user set up (`xavier-cli`)
- [x] AWS CLI + Terraform installed locally
- [x] S3 bucket created (`xavier-mckenzie-resume-2026`, private, public access blocked)
- [x] Site files uploaded to S3
- [x] CloudFront distribution live over HTTPS via Origin Access Control (OAC)
      — https://dj7y9pr9j39io.cloudfront.net (distribution `E73WN659MK4UQ`)
- [~] Custom domain — deliberately skipped for now (cost not worth it yet); site works fine on
      the cloudfront.net URL, can add a domain later without redoing anything above
- [x] DynamoDB visitor counter table (`resume-visitor-count`)
- [x] Lambda backend (`resume-visitor-counter`, Python 3.12, atomic increment via `update_item`)
- [x] API Gateway HTTP API (`GET /count`) wired to Lambda
- [x] Frontend JS calls the API and displays the live count
- [x] Entire stack (S3, CloudFront, DynamoDB, Lambda, IAM role, API Gateway) imported into
      Terraform state — `terraform plan` reports zero drift from what's actually running
- [x] Lambda unit tests (`lambda/tests/`, pytest + moto — mocks DynamoDB, no AWS calls made)
- [ ] AWS Cloud Practitioner cert study started

Built manually first (console/CLI), per the official challenge order, then reconciled into
Terraform as a retroactive IaC pass. The `xavier-cli` IAM user itself and its `resume-project-policy`
attachment are deliberately *not* Terraform-managed — that's the identity running Terraform, so
keeping it outside the tool's blast radius avoids a self-lockout risk.

## Placeholders left in index.html to fix

- Exact CGI internship start date (left blank — fill in when known)

## Note on IAM

`xavier-cli` runs on `resume-project-policy` (`iam/resume-project-policy.json`), scoped to this
project's specific resources (S3 bucket, CloudFront, DynamoDB table, Lambda function, IAM role,
API Gateway, log group). Note: the copy of this file in git has its account ID scrubbed to the
placeholder `123456789012` for public-repo hygiene — the live AWS policy uses the real account ID.

## Tests

`lambda/tests/` — pytest + moto (mocked DynamoDB, no real AWS calls). Run from `lambda/`:

```
pip install -r requirements-dev.txt
python -m pytest tests/ -v
```

## Backend CI/CD

`.github/workflows/backend-deploy.yml` runs Lambda unit tests, then `terraform plan`/`apply`
against the main stack on every push to `main` that touches `lambda/**` or `terraform/**`.
Authenticates to AWS via GitHub OIDC federation (no stored AWS keys) — see
`terraform/bootstrap/main.tf` for the one-time-applied stack that makes this possible: the
remote Terraform state backend (S3 + DynamoDB lock table) and the `resume-cicd-role` IAM role
GitHub Actions assumes. That bootstrap stack is deliberately *not* run by CI itself (chicken-and-
egg: CI needs it to exist before CI can run) — it's applied by hand, once, and left alone.

**One-time setup required before this pipeline works** (not yet done as of this commit):
1. Patch the live `resume-project-policy` (attached to `xavier-cli`) via CloudShell with the
   three new statements in `iam/resume-project-policy.json` (`TerraformStateBucket`,
   `TerraformStateLock`, `BootstrapStackManage`) — swap the placeholder account ID for the real
   one.
2. `cd terraform/bootstrap && terraform init && terraform apply` — creates the state bucket,
   lock table, OIDC provider, and CI role. Note the `github_actions_role_arn` output.
3. In GitHub: Settings → Secrets and variables → Actions → Variables → add
   `AWS_CI_ROLE_ARN` = that output value.
4. `cd terraform && terraform init -migrate-state` — moves existing local state (15 resources)
   into the new S3 backend. `terraform plan` afterward should show zero drift.
5. Push to `main` — the workflow should run tests, then plan/apply against the now-remote state.

## Next step

Backend is fully live, Terraform-managed, unit-tested, and has a CI/CD pipeline defined —
pending the one-time bootstrap apply above. After that: frontend CI/CD, eventually a custom
domain.
