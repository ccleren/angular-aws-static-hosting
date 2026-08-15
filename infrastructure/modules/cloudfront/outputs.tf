output "distribution_id" {
  description = "ID de la distribución de CloudFront."
  value       = aws_cloudfront_distribution.site.id
}

output "distribution_arn" {
  description = "ARN de la distribución de CloudFront (usado para restringir la bucket policy de S3 vía OAC)."
  value       = aws_cloudfront_distribution.site.arn
}

output "domain_name" {
  description = "Dominio *.cloudfront.net asignado a la distribución."
  value       = aws_cloudfront_distribution.site.domain_name
}

output "hosted_zone_id" {
  description = "Hosted zone ID fijo de CloudFront, usado en el alias record de Route 53."
  value       = aws_cloudfront_distribution.site.hosted_zone_id
}

output "url" {
  description = "URL https completa de la distribución."
  value       = "https://${aws_cloudfront_distribution.site.domain_name}"
}
