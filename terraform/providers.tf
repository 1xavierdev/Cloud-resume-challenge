terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}

# NOTE: No custom domain yet, so we're using CloudFront's default
# certificate (*.cloudfront.net). When a domain is added later, an ACM
# certificate will need to be requested in us-east-1 (CloudFront requirement)
# regardless of which region aws_region is set to.
