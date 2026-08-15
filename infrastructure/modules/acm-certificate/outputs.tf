output "certificate_arn" {
  description = "ARN del certificado, ya validado (apunta a aws_acm_certificate_validation para forzar la espera de la validación)."
  value       = aws_acm_certificate_validation.this.certificate_arn
}
