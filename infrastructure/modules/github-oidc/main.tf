# ---------------------------------------------------------------------------
# Permite a GitHub Actions autenticarse en AWS vía OIDC, sin credenciales
# estáticas (access key / secret key) guardadas en GitHub Secrets.
# ---------------------------------------------------------------------------
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.59"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

# El thumbprint del certificado TLS de GitHub lo exige la API de IAM al
# crear el identity provider (aunque AWS ya no lo valide activamente).
data "tls_certificate" "github" {
  count = var.create_oidc_provider ? 1 : 0
  url   = "https://token.actions.githubusercontent.com"
}

# Solo puede existir UN identity provider por URL en cada cuenta de AWS.
# Si ya tienes uno (de otro repositorio/proyecto), pon
# create_oidc_provider = false y pasa su ARN en existing_oidc_provider_arn.
resource "aws_iam_openid_connect_provider" "github" {
  count = var.create_oidc_provider ? 1 : 0

  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.github[0].certificates[0].sha1_fingerprint]

  tags = var.tags
}

locals {
  oidc_provider_arn = var.create_oidc_provider ? aws_iam_openid_connect_provider.github[0].arn : var.existing_oidc_provider_arn
}

# El rol solo puede ser asumido por workflows que corran sobre las ramas
# permitidas del repo indicado — no por cualquier repo de GitHub.
data "aws_iam_policy_document" "trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [local.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = [for branch in var.allowed_branches : "repo:${var.github_org}/${var.github_repo}:ref:refs/heads/${branch}"]
    }
  }
}

resource "aws_iam_role" "deploy" {
  name               = var.role_name
  assume_role_policy = data.aws_iam_policy_document.trust.json
  tags               = var.tags
}

# ---------------------------------------------------------------------------
# Permisos de despliegue. Terraform necesita control de ciclo de vida
# completo sobre S3/CloudFront/ACM/Route53 (los crea, actualiza y podría
# destruirlos), así que la policy se ampara en acciones de servicio,
# acotadas a los recursos que sí se pueden restringir (buckets y tabla del
# backend, bucket del sitio, la hosted zone).
# ---------------------------------------------------------------------------
data "aws_iam_policy_document" "deploy" {
  statement {
    sid    = "TerraformStateAccess"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket",
    ]
    resources = [
      var.state_bucket_arn,
      "${var.state_bucket_arn}/*",
    ]
  }

  statement {
    sid       = "TerraformStateLocking"
    effect    = "Allow"
    actions   = ["dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:DeleteItem"]
    resources = [var.lock_table_arn]
  }

  statement {
    sid    = "SiteBucketManageAndSync"
    effect = "Allow"
    actions = [
      "s3:*",
    ]
    resources = [
      var.site_bucket_arn,
      "${var.site_bucket_arn}/*",
    ]
  }

  statement {
    sid       = "CloudFrontManage"
    effect    = "Allow"
    actions   = ["cloudfront:*"]
    resources = ["*"] # CloudFront no soporta restricción por ARN de recurso para gestión completa vía Terraform.
  }

  statement {
    sid       = "AcmManage"
    effect    = "Allow"
    actions   = ["acm:*"]
    resources = ["*"] # El ARN del certificado no existe hasta crearlo; se acota por acción, no por recurso.
  }

  statement {
    sid    = "Route53Manage"
    effect = "Allow"
    actions = [
      "route53:GetHostedZone",
      "route53:ListHostedZones",
      "route53:ListHostedZonesByName",
      "route53:ChangeResourceRecordSets",
      "route53:ListResourceRecordSets",
      "route53:GetChange",
      "route53:CreateHostedZone",
      "route53:DeleteHostedZone",
      "route53:ChangeTagsForResource",
      "route53:ListTagsForResource",
    ]
    resources = ["*"] # Las hosted zones no tienen ARN utilizable en resources hasta que existen.
  }
}

resource "aws_iam_role_policy" "deploy" {
  name   = "${var.role_name}-deploy"
  role   = aws_iam_role.deploy.id
  policy = data.aws_iam_policy_document.deploy.json
}
