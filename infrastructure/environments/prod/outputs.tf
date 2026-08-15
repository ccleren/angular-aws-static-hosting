output "cloudfront_url" {
  description = "URL *.cloudfront.net de la distribución (útil antes de que el DNS propague)."
  value       = module.cloudfront.url
}

output "cloudfront_distribution_id" {
  description = "ID de la distribución de CloudFront, usado por el workflow de CI/CD para invalidar la caché tras cada despliegue."
  value       = module.cloudfront.distribution_id
}

output "site_url" {
  description = "URL final del sitio, sobre el dominio propio."
  value       = "https://${var.domain_name}"
}

output "route53_name_servers" {
  description = "Nameservers de la hosted zone. Si create_route53_zone = true, hay que configurarlos en el registrador del dominio para que el DNS resuelva."
  value       = module.route53.name_servers
}

output "bucket_name" {
  description = "Nombre del bucket S3 donde se sincroniza el build de Angular en cada despliegue."
  value       = module.s3_static_site.bucket_id
}

output "acm_certificate_arn" {
  description = "ARN del certificado ACM (us-east-1) usado por CloudFront."
  value       = module.acm_certificate.certificate_arn
}

output "github_actions_role_arn" {
  description = "ARN del rol IAM que asume el workflow de GitHub Actions vía OIDC. Configúralo como variable/secreto AWS_ROLE_ARN en el repositorio."
  value       = module.github_oidc.role_arn
}
