output "bucket_name" {
  value = aws_s3_bucket.resume.id
}

output "cloudfront_domain_name" {
  value       = aws_cloudfront_distribution.resume.domain_name
  description = "Live site URL is https://<this value>"
}

output "cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.resume.id
}
