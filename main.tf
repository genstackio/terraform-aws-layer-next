locals {
  lambdas = concat(
    (null != var.lambdas) ? var.lambdas : [],
    [
      {event_type = "origin-request", lambda_arn = module.lambda-proxy.qualified_arn, include_body = false},
    ]
  )
  lambda_proxy_name = (null != var.lambda_proxy_name) ? var.lambda_proxy_name : "${replace(var.dns, ".", "-")}-proxy"
}

module "website" {
  source               = "genstackio/website/aws"
  version              = "0.1.25"
  name                 = var.name
  bucket_name          = var.bucket_name
  zone                 = var.dns_zone
  dns                  = var.dns
  geolocations         = var.geolocations
  forward_query_string = true
  forwarded_headers    = ["*"]
  apex_redirect        = var.apex_redirect
  lambdas              = local.lambdas
  log_group_regions    = var.log_group_regions
  providers            = {
    aws     = aws
    aws.acm = aws.acm
  }
}

module "lambda-proxy" {
  source      = "genstackio/website/aws//modules/lambda-proxy"
  version     = "0.1.24"
  name        = local.lambda_proxy_name
  config_file = "${path.module}/config.js"
}
