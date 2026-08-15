variable "domain_name" {
  description = "Dominio raíz gestionado por la hosted zone, ej. \"example.com\"."
  type        = string

  validation {
    condition     = can(regex("^([a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?\\.)+[a-z]{2,}$", var.domain_name))
    error_message = "domain_name debe ser un dominio válido (ej. \"example.com\"), sin protocolo ni rutas."
  }
}

variable "create_zone" {
  description = "Si es true, crea una hosted zone nueva. Si es false, usa una hosted zone ya existente para var.domain_name."
  type        = bool
  default     = true
}

variable "additional_subdomains" {
  description = "Subdominios adicionales (sin el dominio) que también apuntan a CloudFront, ej. [\"www\"]."
  type        = list(string)
  default     = []
}

variable "cloudfront_domain_name" {
  description = "Dominio *.cloudfront.net de la distribución (output del módulo cloudfront)."
  type        = string
}

variable "cloudfront_hosted_zone_id" {
  description = "Hosted zone ID fijo de CloudFront (output del módulo cloudfront)."
  type        = string
}

variable "tags" {
  description = "Tags aplicados a la hosted zone (solo si create_zone = true)."
  type        = map(string)
  default     = {}
}
