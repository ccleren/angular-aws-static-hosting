variable "aws_region" {
  description = "Región de AWS donde se crean el bucket de state y la tabla de locking."
  type        = string
  default     = "eu-west-1"
}

variable "state_bucket_name" {
  description = "Nombre (globalmente único) del bucket S3 que guardará el remote state de Terraform."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.state_bucket_name))
    error_message = "state_bucket_name debe tener 3-63 caracteres, solo minúsculas, números, puntos y guiones, y empezar/terminar con un carácter alfanumérico (reglas de nombrado de S3)."
  }
}

variable "lock_table_name" {
  description = "Nombre de la tabla DynamoDB usada para el locking del state."
  type        = string
  default     = "terraform-state-locks"
}

variable "tags" {
  description = "Tags aplicados a todos los recursos del bootstrap."
  type        = map(string)
  default     = {}
}
