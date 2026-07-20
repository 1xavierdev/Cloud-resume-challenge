# Site content (index.html/style.css/script.js) used to be uploaded here via
# aws_s3_object resources, keyed off a filemd5 etag — a stopgap from Week 2
# before a real CI/CD pipeline existed. Removed 2026-07-19 in favor of
# .github/workflows/frontend-deploy.yml, which syncs those files directly to
# S3 and invalidates CloudFront on push, independent of this stack's
# plan/apply cycle. The resources were removed from Terraform's state with
# `terraform state rm` (not destroyed) so the live files were never touched
# — Terraform simply stopped tracking them. Nothing else in this stack
# depends on them; the bucket itself is still managed in s3.tf.
