output "bucket_id" {
  description = "Nombre (id) del bucket S3."
  value       = aws_s3_bucket.site.id
}

output "bucket_arn" {
  description = "ARN del bucket S3."
  value       = aws_s3_bucket.site.arn
}

output "bucket_regional_domain_name" {
  description = "Nombre de dominio regional del bucket, usado como origin de CloudFront."
  value       = aws_s3_bucket.site.bucket_regional_domain_name
}
