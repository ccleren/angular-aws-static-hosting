# ---------------------------------------------------------------------------
# Bucket privado para el build estático de Angular.
# El acceso público está bloqueado por completo: el único lector autorizado
# es la distribución de CloudFront, vía Origin Access Control (OAC).
# ---------------------------------------------------------------------------
resource "aws_s3_bucket" "site" {
  bucket = var.bucket_name

  tags = merge(var.tags, {
    Name = var.bucket_name
  })
}

resource "aws_s3_bucket_versioning" "site" {
  bucket = aws_s3_bucket.site.id

  versioning_configuration {
    status = var.versioning_enabled ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "site" {
  bucket = aws_s3_bucket.site.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "site" {
  bucket = aws_s3_bucket.site.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# La policy solo se crea una vez que existe la distribución de CloudFront
# (var.cloudfront_distribution_arn), para poder restringir el acceso
# exclusivamente a esa distribución vía la condición AWS:SourceArn.
data "aws_iam_policy_document" "cloudfront_oac_access" {
  count = var.cloudfront_distribution_arn != null ? 1 : 0

  statement {
    sid    = "AllowCloudFrontServicePrincipalReadOnly"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.site.arn}/*"]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [var.cloudfront_distribution_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "cloudfront_oac_access" {
  count = var.cloudfront_distribution_arn != null ? 1 : 0

  bucket = aws_s3_bucket.site.id
  policy = data.aws_iam_policy_document.cloudfront_oac_access[0].json

  depends_on = [aws_s3_bucket_public_access_block.site]
}
