resource "aws_cloudfront_origin_access_control" "resume" {
  name                              = "resume-oac"
  description                       = ""
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "resume" {
  enabled             = true
  comment             = "Cloud Resume Challenge site"
  default_root_object = "index.html"
  price_class         = "PriceClass_100" # cheapest tier: US/Canada/Europe edge locations only
  is_ipv6_enabled     = true

  origin {
    domain_name              = aws_s3_bucket.resume.bucket_regional_domain_name
    origin_id                = "s3-resume-origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.resume.id
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "s3-resume-origin"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    # AWS-managed "CachingOptimized" policy -- standard choice for static sites.
    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
