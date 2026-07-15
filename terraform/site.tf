# Uploads the static site files directly. This is a stopgap for Week 2 --
# it'll get replaced by a proper CI/CD pipeline (GitHub Actions) in a later
# step of the challenge. For now, `terraform apply` both provisions
# infrastructure and pushes the current file contents.
locals {
  site_files = {
    "index.html" = "text/html"
    "style.css"  = "text/css"
    "script.js"  = "application/javascript"
  }
}

resource "aws_s3_object" "site_files" {
  for_each = local.site_files

  bucket       = aws_s3_bucket.resume.id
  key          = each.key
  source       = "${path.module}/../${each.key}"
  etag         = filemd5("${path.module}/../${each.key}")
  content_type = each.value
}
