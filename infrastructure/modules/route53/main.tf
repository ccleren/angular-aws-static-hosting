resource "aws_route53_zone" "this" {
  count = var.create_zone ? 1 : 0

  name = var.domain_name
  tags = var.tags
}

data "aws_route53_zone" "existing" {
  count = var.create_zone ? 0 : 1

  name         = var.domain_name
  private_zone = false
}

locals {
  zone_id = var.create_zone ? aws_route53_zone.this[0].zone_id : data.aws_route53_zone.existing[0].zone_id
}

# Registro A (Alias) del dominio raíz hacia CloudFront.
resource "aws_route53_record" "apex" {
  zone_id = local.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = var.cloudfront_domain_name
    zone_id                = var.cloudfront_hosted_zone_id
    evaluate_target_health = false
  }
}

# Registro A (Alias) opcional para subdominios adicionales, p.ej. "www".
resource "aws_route53_record" "aliases" {
  for_each = toset(var.additional_subdomains)

  zone_id = local.zone_id
  name    = "${each.value}.${var.domain_name}"
  type    = "A"

  alias {
    name                   = var.cloudfront_domain_name
    zone_id                = var.cloudfront_hosted_zone_id
    evaluate_target_health = false
  }
}
