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
- [x] Backend CI/CD (GitHub Actions, OIDC-authenticated, runs tests then `terraform plan`/`apply`
      on push to `main`)
- [ ] Frontend CI/CD
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

**Setup, for reference** (already done — bootstrap stack is live):
1. Patch the live `resume-project-policy` (attached to `xavier-cli`) via CloudShell with the
   statements in `iam/resume-project-policy.json` (`TerraformStateBucket`, `TerraformStateLock`,
   `BootstrapStackManage`) — swap the placeholder account ID for the real one.
2. `cd terraform/bootstrap && terraform init && terraform apply` — creates the state bucket,
   lock table, OIDC provider, and CI role.
3. In GitHub: Settings → Secrets and variables → Actions → Variables → add
   `AWS_CI_ROLE_ARN` = the `github_actions_role_arn` output from step 2.
4. `cd terraform && terraform init -migrate-state` — moves local state into the new S3 backend.
5. Push to `main`.

**One real gotcha worth knowing if this ever needs rebuilding:** GitHub's OIDC tokens embed the
owner's and repo's numeric IDs in the `sub` claim (`repo:OWNER@OWNER_ID/REPO@REPO_ID:ref:...`),
not just names (`repo:OWNER/REPO:ref:...`) like most tutorials assume. The name-only format looks
completely correct and matches AWS's own example trust policies, but silently never matches any
real token GitHub issues — `AssumeRoleWithWebIdentity` just fails with a generic AccessDenied that
gives no hint the trust policy's condition is the actual problem. `terraform/bootstrap/main.tf`
now builds the condition from `github_owner_id`/`github_repo_id` in `variables.tf`. If this ever
needs redoing for a different repo, get the real IDs first:
`curl -s https://api.github.com/repos/OWNER/REPO | jq '.owner.id, .id'` — or decode an actual
issued token (add a debug step that curls `$ACTIONS_ID_TOKEN_REQUEST_URL`) rather than assuming
the name-only format is right.

Also worth knowing: the CI role's own IAM policy (in `terraform/bootstrap/main.tf`) needs to stay
in sync with whatever `resume-project-policy.json` accumulates — they're separate policies for
separate identities (human vs. pipeline) covering the same resources, so a permission added to one
doesn't automatically apply to the other.

## Next step

Backend is fully live, Terraform-managed, unit-tested, and auto-deploys via CI/CD on push to
`main`. Next: frontend CI/CD (sync `index.html`/`script.js`/`style.css` to S3, invalidate
CloudFront), eventually a custom domain.
