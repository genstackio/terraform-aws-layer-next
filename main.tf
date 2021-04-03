locals {
  forwarded_headers = concat(
    (null != var.forwarded_headers) ? var.forwarded_headers : [],
    [
      "CloudFront-Is-Android-Viewer",
      "CloudFront-Is-Desktop-Viewer",
      "CloudFront-Is-IOS-Viewer",
      "CloudFront-Is-Mobile-Viewer",
      "CloudFront-Is-SmartTV-Viewer",
      "CloudFront-Is-Tablet-Viewer",
      "CloudFront-Viewer-City",
      "CloudFront-Viewer-Country",
      "CloudFront-Viewer-Country-Name",
      "CloudFront-Viewer-Country-Region",
      "CloudFront-Viewer-Country-Region-Name",
      "CloudFront-Viewer-Latitude",
      "CloudFront-Viewer-Longitude",
      "CloudFront-Viewer-Metro-Code",
      "CloudFront-Viewer-Postal-Code",
      "CloudFront-Viewer-Time-Zone",
      "CloudFront-Forwarded-Proto",
      "CloudFront-Viewer-Http-Version",
    ]
  )
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
  version              = "0.1.24"
  name                 = var.name
  bucket_name          = var.bucket_name
  zone                 = var.dns_zone
  dns                  = var.dns
  geolocations         = var.geolocations
  forward_query_string = true
  forwarded_headers    = local.forwarded_headers
  apex_redirect        = var.apex_redirect
  lambdas              = local.lambdas
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
