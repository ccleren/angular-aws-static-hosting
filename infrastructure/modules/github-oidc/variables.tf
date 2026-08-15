variable "github_org" {
  description = "Organización o usuario de GitHub dueño del repositorio, p.ej. \"ccleren\"."
  type        = string
}

variable "github_repo" {
  description = "Nombre del repositorio de GitHub, p.ej. \"angular-aws-static-hosting\"."
  type        = string
}

variable "allowed_branches" {
  description = "Ramas desde las que un workflow puede asumir el rol de despliegue."
  type        = list(string)
  default     = ["main"]
}

variable "create_oidc_provider" {
  description = <<-EOT
    Si es true, crea el identity provider OIDC de GitHub en la cuenta de AWS.
    Solo puede existir uno por cuenta: si ya tienes uno de otro proyecto,
    pon esto a false y pasa su ARN en existing_oidc_provider_arn.
  EOT
  type        = bool
  default     = true
}

variable "existing_oidc_provider_arn" {
  description = "ARN del identity provider OIDC de GitHub ya existente en la cuenta (solo se usa si create_oidc_provider = false)."
  type        = string
  default     = null
}

variable "role_name" {
  description = "Nombre del rol IAM que asume GitHub Actions para desplegar."
  type        = string
  default     = "github-actions-deploy"
}

variable "state_bucket_arn" {
  description = "ARN del bucket S3 del remote state de Terraform (creado en el bootstrap)."
  type        = string
}

variable "lock_table_arn" {
  description = "ARN de la tabla DynamoDB de locking del state (creada en el bootstrap)."
  type        = string
}

variable "site_bucket_arn" {
  description = "ARN del bucket S3 donde se sincroniza el build de Angular."
  type        = string
}

variable "tags" {
  description = "Tags aplicados a los recursos IAM."
  type        = map(string)
  default     = {}
}
