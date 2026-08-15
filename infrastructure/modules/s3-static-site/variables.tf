variable "bucket_name" {
  description = "Nombre (globalmente único) del bucket S3 que alojará el build estático."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.bucket_name))
    error_message = "bucket_name debe tener 3-63 caracteres, solo minúsculas, números, puntos y guiones, y empezar/terminar con un carácter alfanumérico (reglas de nombrado de S3)."
  }
}

variable "versioning_enabled" {
  description = "Si se habilita el versioning del bucket."
  type        = bool
  default     = true
}

variable "cloudfront_distribution_arn" {
  description = <<-EOT
    ARN de la distribución de CloudFront autorizada a leer el bucket vía OAC.
    En el entorno prod se pasa siempre el output del módulo cloudfront;
    Terraform resuelve el orden de creación (bucket → distribución →
    bucket policy) automáticamente en un único apply gracias al grafo de
    dependencias. Se deja como nullable para poder instanciar este módulo
    de forma aislada (tests, otros usos) sin necesitar una distribución.
  EOT
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags aplicados a todos los recursos del módulo."
  type        = map(string)
  default     = {}
}
