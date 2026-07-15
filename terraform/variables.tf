variable "aws_region" {
  description = "AWS region for the S3 bucket. CloudFront itself is global regardless of this setting."
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "S3 bucket name for the static site. Fixed (not randomized) to match the bucket created manually in Week 2."
  type        = string
  default     = "xavier-mckenzie-resume-2026"
}
