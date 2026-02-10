output "bucket_name" {
  description = "S3 bucket name used for the site"
  value       = aws_s3_bucket.site.bucket
}

output "cloudfront_domain" {
  description = "CloudFront distribution domain name"
  value       = aws_cloudfront_distribution.cdn.domain_name
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution id"
  value       = aws_cloudfront_distribution.cdn.id
}
