variable "aws_region" {
  description = "Región de AWS para los recursos regionales (S3, Route 53). CloudFront es global y ACM se fuerza a us-east-1 aparte."
  type        = string
  default     = "eu-west-1"
}

variable "domain_name" {
  description = "Dominio raíz de la aplicación, p.ej. \"example.com\"."
  type        = string

  validation {
    condition     = can(regex("^([a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?\\.)+[a-z]{2,}$", var.domain_name))
    error_message = "domain_name debe ser un dominio válido (ej. \"example.com\"), sin protocolo ni rutas."
  }
}

variable "additional_subdomains" {
  description = "Subdominios adicionales que también sirven la app, p.ej. [\"www\"]."
  type        = list(string)
  default     = ["www"]
}

variable "create_route53_zone" {
  description = "Si es true, Terraform crea la hosted zone de Route 53. Si es false, debe existir ya una hosted zone pública para var.domain_name."
  type        = bool
  default     = true
}

variable "bucket_name" {
  description = "Nombre (globalmente único) del bucket S3 que aloja el build de Angular. También se usa como prefijo de nombre para los recursos de CloudFront."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.bucket_name))
    error_message = "bucket_name debe tener 3-63 caracteres, solo minúsculas, números, puntos y guiones, y empezar/terminar con un carácter alfanumérico (reglas de nombrado de S3)."
  }
}

variable "cloudfront_price_class" {
  description = "Price class de CloudFront (PriceClass_100 | PriceClass_200 | PriceClass_All)."
  type        = string
  default     = "PriceClass_100"
}

variable "github_org" {
  description = "Organización o usuario de GitHub dueño del repositorio (para el rol OIDC de CI/CD)."
  type        = string
}

variable "github_repo" {
  description = "Nombre del repositorio de GitHub (para el rol OIDC de CI/CD)."
  type        = string
}

variable "allowed_branches" {
  description = "Ramas desde las que el workflow de GitHub Actions puede desplegar."
  type        = list(string)
  default     = ["main"]
}

variable "create_github_oidc_provider" {
  description = "Si es true, crea el identity provider OIDC de GitHub. Ponlo a false si tu cuenta de AWS ya tiene uno (de otro proyecto)."
  type        = bool
  default     = true
}

variable "existing_github_oidc_provider_arn" {
  description = "ARN del identity provider OIDC de GitHub ya existente (solo si create_github_oidc_provider = false)."
  type        = string
  default     = null
}

variable "state_bucket_name" {
  description = "Nombre del bucket S3 del remote state (creado en infrastructure/bootstrap), usado para acotar los permisos del rol de CI/CD."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.state_bucket_name))
    error_message = "state_bucket_name debe tener 3-63 caracteres, solo minúsculas, números, puntos y guiones, y empezar/terminar con un carácter alfanumérico (reglas de nombrado de S3)."
  }
}

variable "lock_table_name" {
  description = "Nombre de la tabla DynamoDB de locking (creada en infrastructure/bootstrap), usado para acotar los permisos del rol de CI/CD."
  type        = string
  default     = "terraform-state-locks"
}

variable "tags" {
  description = "Tags aplicados a todos los recursos del entorno."
  type        = map(string)
  default = {
    Project     = "angular-aws-static-hosting"
    Environment = "prod"
    ManagedBy   = "terraform"
  }
}
