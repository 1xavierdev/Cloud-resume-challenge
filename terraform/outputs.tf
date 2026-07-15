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

output "api_endpoint" {
  value       = "${aws_apigatewayv2_api.visitor_api.api_endpoint}/count"
  description = "Visitor counter API endpoint"
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.visitor_count.name
}

output "lambda_function_name" {
  value = aws_lambda_function.visitor_counter.function_name
}
