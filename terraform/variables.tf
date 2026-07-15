variable "aws_region" {
  description = "AWS region for the S3 bucket. CloudFront itself is global regardless of this setting."
  type        = string
  default     = "us-east-1"
}

variable "bucket_name_prefix" {
  description = "Prefix for the S3 bucket name. A random hex suffix is appended for global uniqueness."
  type        = string
  default     = "xavier-mckenzie-resume"
}
