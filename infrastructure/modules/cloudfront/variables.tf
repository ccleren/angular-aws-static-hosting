variable "name_prefix" {
  description = "Prefijo usado para nombrar los recursos de CloudFront (OAC, response headers policy, origin id)."
  type        = string
}

variable "bucket_regional_domain_name" {
  description = "Nombre de dominio regional del bucket S3 origin (output del módulo s3-static-site)."
  type        = string
}

variable "acm_certificate_arn" {
  description = "ARN del certificado ACM (debe existir en us-east-1) usado por la distribución."
  type        = string
}

variable "domain_aliases" {
  description = "Dominios (CNAMEs) que sirve la distribución, ej. [\"example.com\", \"www.example.com\"]."
  type        = list(string)
  default     = []
}

variable "default_root_object" {
  description = "Objeto raíz servido por defecto y usado como destino de los custom error responses (SPA routing)."
  type        = string
  default     = "index.html"
}

variable "price_class" {
  description = "Price class de CloudFront. PriceClass_100 limita la distribución a EE.UU./Europa (más barato)."
  type        = string
  default     = "PriceClass_100"
}

variable "cache_policy_id" {
  description = "ID de la cache policy usada por el default cache behavior. Por defecto, la managed policy \"CachingOptimized\" de AWS."
  type        = string
  default     = "658327ea-f89d-4fab-a63d-7e88639e58f6" # CachingOptimized (managed by AWS)
}

variable "content_security_policy" {
  description = "Valor de la cabecera Content-Security-Policy aplicada por la response headers policy."
  type        = string
  default     = "default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; font-src 'self' https://fonts.gstatic.com; img-src 'self' data:; connect-src 'self'; object-src 'none'; base-uri 'self'; frame-ancestors 'none'"
}

variable "tags" {
  description = "Tags aplicados a la distribución de CloudFront."
  type        = map(string)
  default     = {}
}
