output "state_bucket_name" {
  description = "Nombre del bucket S3 creado para el remote state."
  value       = aws_s3_bucket.terraform_state.id
}

output "state_bucket_arn" {
  description = "ARN del bucket S3 creado para el remote state."
  value       = aws_s3_bucket.terraform_state.arn
}

output "lock_table_name" {
  description = "Nombre de la tabla DynamoDB creada para el locking del state."
  value       = aws_dynamodb_table.terraform_locks.name
}
