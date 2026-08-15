# ---------------------------------------------------------------------------
# Origin Access Control — sustituye a OAI para dar a CloudFront
# acceso exclusivo al bucket S3 privado.
# ---------------------------------------------------------------------------
resource "aws_cloudfront_origin_access_control" "site" {
  name                              = "${var.name_prefix}-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# ---------------------------------------------------------------------------
# Cabeceras de seguridad aplicadas a toda respuesta servida por CloudFront.
# ---------------------------------------------------------------------------
resource "aws_cloudfront_response_headers_policy" "security_headers" {
  name = "${var.name_prefix}-security-headers"

  security_headers_config {
    strict_transport_security {
      override                   = true
      access_control_max_age_sec = 63072000 # 2 años
      include_subdomains         = true
      preload                    = true
    }

    content_type_options {
      override = true
    }

    frame_options {
      override     = true
      frame_option = "DENY"
    }

    referrer_policy {
      override        = true
      referrer_policy = "strict-origin-when-cross-origin"
    }

    content_security_policy {
      override                = true
      content_security_policy = var.content_security_policy
    }
  }
}

# ---------------------------------------------------------------------------
# Distribución de CloudFront
# ---------------------------------------------------------------------------
resource "aws_cloudfront_distribution" "site" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = var.name_prefix
  default_root_object = var.default_root_object
  price_class         = var.price_class
  aliases             = var.domain_aliases
  web_acl_id          = null

  origin {
    domain_name              = var.bucket_regional_domain_name
    origin_id                = local.origin_id
    origin_access_control_id = aws_cloudfront_origin_access_control.site.id
  }

  default_cache_behavior {
    target_origin_id       = local.origin_id
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true

    cache_policy_id            = var.cache_policy_id
    response_headers_policy_id = aws_cloudfront_response_headers_policy.security_headers.id
  }

  # Client-side routing de Angular: cualquier ruta desconocida para S3
  # (403 porque el objeto no existe, o 404) se sirve como index.html con
  # código 200 para que el Router de Angular tome el control.
  custom_error_response {
    error_code            = 403
    response_code         = 200
    response_page_path    = "/${var.default_root_object}"
    error_caching_min_ttl = 10
  }

  custom_error_response {
    error_code            = 404
    response_code         = 200
    response_page_path    = "/${var.default_root_object}"
    error_caching_min_ttl = 10
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  tags = var.tags
}

locals {
  origin_id = "${var.name_prefix}-s3-origin"
}
