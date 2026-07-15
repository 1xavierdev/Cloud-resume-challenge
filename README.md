# Cloud Resume Challenge — Xavier McKenzie

Tracking my build of the [Cloud Resume Challenge](https://cloudresumechallenge.dev/docs/the-challenge/aws/) (AWS, Terraform variant).

## Status: Week 2

- [x] HTML resume drafted (`index.html`)
- [x] CSS styling (`style.css`)
- [x] AWS account + IAM user set up (`xavier-cli`, account 123456789012)
- [x] AWS CLI + Terraform installed locally
- [x] S3 bucket created (`xavier-mckenzie-resume-2026`, private, public access blocked)
- [x] Site files uploaded to S3
- [x] CloudFront distribution live over HTTPS via Origin Access Control (OAC)
      — https://dj7y9pr9j39io.cloudfront.net (distribution `E73WN659MK4UQ`)
- [~] Custom domain — deliberately skipped for now (cost not worth it yet); site works fine on
      the cloudfront.net URL, can add a domain later without redoing anything above
- [ ] AWS Cloud Practitioner cert study started

Built manually first (console/CLI), per the official challenge order — Terraform comes back into
play as its own later step (Infrastructure as Code), applied retroactively to what's already
running. Draft `.tf` files for this stage already exist under `terraform/` for that step.

## Placeholders left in index.html to fix

- Exact CGI internship start date (left blank — fill in when known)

## Note on IAM

`xavier-cli` now runs on `resume-project-policy` (`iam/resume-project-policy.json`), scoped to S3
access on this bucket only + CloudFront management. `AdministratorAccess` has been detached. This
policy will need additions as later steps add Lambda/DynamoDB/API Gateway.

## Next step

Week 2 core is done (S3 + CloudFront + HTTPS, IAM scoped down). Move on to Week 3+: JavaScript,
DynamoDB visitor counter, API Gateway + Lambda.
