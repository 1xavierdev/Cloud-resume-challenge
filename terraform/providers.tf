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

  # Bucket/table created once by terraform/bootstrap (see that directory's
  # README note) — CI runners are ephemeral and can't rely on a local
  # terraform.tfstate file, so this has to exist before CI can plan/apply.
  # Backend blocks can't reference variables, hence the literal names here
  # matching terraform/bootstrap/variables.tf's defaults.
  backend "s3" {
    bucket         = "xavier-mckenzie-resume-2026-tfstate"
    key            = "cloud-resume-challenge/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "resume-terraform-locks"
    encrypt        = true
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
