terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

data "aws_caller_identity" "current" {}

# Provider "principal": región donde viven S3, la hosted zone de Route 53
# y (si aplica) el resto de recursos regionales.
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.tags
  }
}

# CloudFront exige que el certificado ACM exista en us-east-1,
# independientemente de la región elegida arriba.
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"

  default_tags {
    tags = var.tags
  }
}

# ---------------------------------------------------------------------------
# Route 53 — la hosted zone se resuelve primero: su zone_id lo necesita ACM
# para los registros de validación DNS. El registro alias hacia CloudFront
# se completa más tarde, cuando la distribución ya existe (ver el módulo).
# ---------------------------------------------------------------------------
module "route53" {
  source = "../../modules/route53"

  domain_name               = var.domain_name
  create_zone               = var.create_route53_zone
  additional_subdomains     = var.additional_subdomains
  cloudfront_domain_name    = module.cloudfront.domain_name
  cloudfront_hosted_zone_id = module.cloudfront.hosted_zone_id
  tags                      = var.tags
}

# ---------------------------------------------------------------------------
# ACM — certificado en us-east-1, validado por DNS contra la zona anterior.
# ---------------------------------------------------------------------------
module "acm_certificate" {
  source = "../../modules/acm-certificate"

  providers = {
    aws = aws.us_east_1
  }

  domain_name               = var.domain_name
  subject_alternative_names = [for sub in var.additional_subdomains : "${sub}.${var.domain_name}"]
  route53_zone_id           = module.route53.zone_id
  tags                      = var.tags
}

# ---------------------------------------------------------------------------
# S3 — bucket privado para el build de Angular. La bucket policy se añade
# una vez existe la distribución de CloudFront (var.cloudfront_distribution_arn).
# ---------------------------------------------------------------------------
module "s3_static_site" {
  source = "../../modules/s3-static-site"

  bucket_name                 = var.bucket_name
  cloudfront_distribution_arn = module.cloudfront.distribution_arn
  tags                        = var.tags
}

# ---------------------------------------------------------------------------
# CloudFront — distribución con OAC hacia S3 y el certificado de ACM.
# ---------------------------------------------------------------------------
module "cloudfront" {
  source = "../../modules/cloudfront"

  name_prefix                 = var.bucket_name
  bucket_regional_domain_name = module.s3_static_site.bucket_regional_domain_name
  acm_certificate_arn         = module.acm_certificate.certificate_arn
  domain_aliases              = concat([var.domain_name], [for sub in var.additional_subdomains : "${sub}.${var.domain_name}"])
  price_class                 = var.cloudfront_price_class
  tags                        = var.tags
}

# ---------------------------------------------------------------------------
# GitHub OIDC — rol IAM que el workflow de CI/CD asume para desplegar,
# sin credenciales estáticas en GitHub Secrets.
# ---------------------------------------------------------------------------
module "github_oidc" {
  source = "../../modules/github-oidc"

  github_org                 = var.github_org
  github_repo                = var.github_repo
  allowed_branches           = var.allowed_branches
  create_oidc_provider       = var.create_github_oidc_provider
  existing_oidc_provider_arn = var.existing_github_oidc_provider_arn

  state_bucket_arn = "arn:aws:s3:::${var.state_bucket_name}"
  lock_table_arn   = "arn:aws:dynamodb:${var.aws_region}:${data.aws_caller_identity.current.account_id}:table/${var.lock_table_name}"
  site_bucket_arn  = module.s3_static_site.bucket_arn

  tags = var.tags
}
