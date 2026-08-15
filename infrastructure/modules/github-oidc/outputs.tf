output "role_arn" {
  description = "ARN del rol IAM que GitHub Actions asume vía OIDC. Se usa como `role-to-assume` en el workflow de despliegue."
  value       = aws_iam_role.deploy.arn
}
