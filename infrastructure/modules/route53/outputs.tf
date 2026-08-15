output "zone_id" {
  description = "ID de la hosted zone (creada o existente)."
  value       = local.zone_id
}

output "name_servers" {
  description = "Nameservers de la hosted zone. Si create_zone = true, hay que configurarlos en el registrador del dominio."
  value       = var.create_zone ? aws_route53_zone.this[0].name_servers : data.aws_route53_zone.existing[0].name_servers
}
