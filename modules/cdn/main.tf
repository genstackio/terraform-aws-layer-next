resource "aws_cloudfront_origin_access_identity" "oai" {
}

resource "aws_cloudfront_distribution" "webapp" {
  // statics => /_next/static/* (to be fetched with path '/statics/_next/static/*' on the s3 bucket)
  origin {
    domain_name = var.s3_master_domain_name // unused domain name
    origin_id   = "statics"
    origin_path = "/statics"
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }
  // cached => /* (to be tried with path '/dynamics/*' on the s3 bucket)
  origin {
    domain_name = var.s3_master_domain_name // unused domain name
    origin_id   = "cached"
    origin_path = "/dynamics"
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }
  // servers => /* (failover: after having tried 'cached' origin, this one is calling the api-gateway with Nextjs lambda)
  origin {
    domain_name = "servers.origins.genstackio.io" // unused domain name
    origin_id   = "servers"
    custom_header {
      name  = "X-Forwarded-For"
      value = var.dns
    }
    custom_origin_config {
      http_port = 80
      https_port = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols = ["TLSv1.2"]
    }
  }
  // publics => /*.* (to be fetched with path '/publics/*.*' on the s3 bucket)
  origin {
    domain_name = var.s3_master_domain_name // unused domain name
    origin_id   = "publics"
    origin_path = "/publics"
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }
  // failover origin group to be used for generated pages (potentially cached on the 'cached' origin)
  origin_group {
    origin_id = "dynamics"
    failover_criteria {
      status_codes = ["404", "403"]
    }
    member {
      origin_id = "cached"
    }
    member {
      origin_id = "servers"
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = length(var.geolocations) == 0 ? "none" : "whitelist"
      locations        = length(var.geolocations) == 0 ? null : var.geolocations
    }
  }

  tags = {
  }

  viewer_certificate {
    acm_certificate_arn      = var.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1"
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "HA Next.js ${var.name} CloudFront CDN Distribution"
  default_root_object = null
  aliases             = local.dnses
  price_class         = var.price_class

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "dynamics"
    compress         = true

    forwarded_values {
      query_string = true
      cookies {
        forward = "all"
      }
      headers = ["*"]
    }

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    viewer_protocol_policy = "redirect-to-https"

    lambda_function_association {
      event_type   = "origin-request"
      lambda_arn   = module.lambda-redirect.qualified_arn
      include_body = false
    }
    lambda_function_association {
      event_type   = "origin-response"
      lambda_arn   = module.lambda-security.qualified_arn
      include_body = false
    }
  }

  ordered_cache_behavior {
    path_pattern             = "/_next/static/*"
    allowed_methods          = ["GET", "HEAD", "OPTIONS"]
    cached_methods           = ["GET", "HEAD"]
    target_origin_id         = "statics"
    viewer_protocol_policy   = "redirect-to-https"
    cache_policy_id          = data.aws_cloudfront_cache_policy.managed_caching_optimized.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.managed_cors_s3_origin.id
    compress                 = true
  }

  ordered_cache_behavior {
    path_pattern             = "/*.*"
    allowed_methods          = ["GET", "HEAD", "OPTIONS"]
    cached_methods           = ["GET", "HEAD"]
    target_origin_id         = "publics"
    viewer_protocol_policy   = "redirect-to-https"
    cache_policy_id          = data.aws_cloudfront_cache_policy.managed_caching_optimized.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.managed_cors_s3_origin.id
    compress                 = true
  }

  ordered_cache_behavior {
    path_pattern             = "/api/*"
    allowed_methods          = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods           = ["GET", "HEAD"]
    target_origin_id         = "servers"
    viewer_protocol_policy   = "redirect-to-https"
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.managed_cors_s3_origin.id
    compress                 = true
    min_ttl                  = 0
    default_ttl              = 3600
    max_ttl                  = 86400
    forwarded_values {
      query_string = true
      cookies {
        forward = "all"
      }
      headers = ["*"]
    }
  }

  ordered_cache_behavior {
    path_pattern             = "/*"
    allowed_methods          = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods           = ["GET", "HEAD"]
    target_origin_id         = "dynamics"
    viewer_protocol_policy   = "redirect-to-https"
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.managed_cors_s3_origin.id
    compress                 = true
    min_ttl                  = 0
    default_ttl              = 3600
    max_ttl                  = 86400
    forwarded_values {
      query_string = true
      cookies {
        forward = "all"
      }
      headers = ["*"]
    }
  }

  dynamic "ordered_cache_behavior" {
    for_each = var.custom_behaviors != null ? var.custom_behaviors : []
    content {
      path_pattern             = ordered_cache_behavior.value["path_pattern"]
      allowed_methods          = lookup(ordered_cache_behavior.value, "allowed_methods", ["GET", "HEAD"])
      cached_methods           = lookup(ordered_cache_behavior.value, "cached_methods", ["GET", "HEAD"])
      target_origin_id         = lookup(ordered_cache_behavior.value, "target_origin_id", "dynamics")
      compress                 = lookup(ordered_cache_behavior.value, "compress", true)
      viewer_protocol_policy   = lookup(ordered_cache_behavior.value, "viewer_protocol_policy", "redirect-to-https")
      origin_request_policy_id = lookup(ordered_cache_behavior.value, "origin_request_policy_id", null)
      cache_policy_id          = lookup(ordered_cache_behavior.value, "cache_policy_id", null)
    }
  }

  custom_error_response {
    error_code         = 403
    response_code      = 403
    response_page_path = "/403"
  }
  custom_error_response {
    error_code         = 404
    response_code      = 404
    response_page_path = "/404"
  }
  custom_error_response {
    error_code         = 500
    response_code      = 500
    response_page_path = "/500"
  }
  custom_error_response {
    error_code         = 502
    response_code      = 502
    response_page_path = "/502"
  }
}

resource "aws_route53_record" "webapp" {
  zone_id = var.zone
  name    = local.dns_0
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.webapp.domain_name
    zone_id                = aws_cloudfront_distribution.webapp.hosted_zone_id
    evaluate_target_health = false
  }
}
resource "aws_route53_record" "webapp_apex" {
  count   = (null != local.dns_1) ? 1 : 0
  zone_id = var.zone
  name    = local.dns_1
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.webapp.domain_name
    zone_id                = aws_cloudfront_distribution.webapp.hosted_zone_id
    evaluate_target_health = false
  }
}

module "lambda-redirect" {
  source      = "genstackio/website/aws//modules/lambda-redirect"
  version     = "0.1.46"
  name        = "${var.name}-redirect"
  config_file = local.redirect_config_file
}

module "lambda-security" {
  source      = "genstackio/website/aws//modules/lambda-security"
  version     = "0.1.46"
  name        = "${var.name}-security"
  config_file = local.security_config_file
}
