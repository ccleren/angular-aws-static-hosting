variable "domain_name" {
  description = "Dominio principal cubierto por el certificado, ej. \"example.com\"."
  type        = string

  validation {
    condition     = can(regex("^([a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?\\.)+[a-z]{2,}$", var.domain_name))
    error_message = "domain_name debe ser un dominio válido (ej. \"example.com\"), sin protocolo ni rutas."
  }
}

variable "subject_alternative_names" {
  description = "Dominios adicionales cubiertos por el certificado, ej. [\"www.example.com\"]."
  type        = list(string)
  default     = []
}

variable "route53_zone_id" {
  description = "ID de la hosted zone de Route 53 donde se crean los registros de validación DNS."
  type        = string
}

variable "tags" {
  description = "Tags aplicados al certificado."
  type        = map(string)
  default     = {}
}
