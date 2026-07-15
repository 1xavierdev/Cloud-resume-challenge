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

## Next step

Backend is fully live and Terraform-managed. Remaining challenge steps: tests, backend CI/CD
(auto-deploy Lambda/Terraform on push), frontend CI/CD, and eventually a custom domain.
