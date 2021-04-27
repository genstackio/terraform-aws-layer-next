locals {
  is_www      = "www." == substr(var.dns, 0, 4)
  dns_0       = var.dns
  dns_1       = var.apex_redirect ? (local.is_www ? substr(var.dns, 4, length(var.dns) - 4) : "www.${var.dns}") : null
  dnses       = concat([local.dns_0], (null != local.dns_1) ? [local.dns_1] : [])
  extra_dnses = (null != local.dns_1) ? [local.dns_1] : null
  redirect_config_file = null == var.redirect_config_file ? "${path.module}/redirect_config.js" : var.redirect_config_file
  security_config_file = null == var.security_config_file ? "${path.module}/security_config.js" : var.security_config_file
  forwarded_headers = [
    "CloudFront-Is-Desktop-Viewer",
    "CloudFront-Is-Tablet-Viewer",
    "CloudFront-Is-Mobile-Viewer",
    "CloudFront-Is-IOS-Viewer",
    "CloudFront-Is-Android-Viewer",
    "CloudFront-Is-SmartTV-Viewer",
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
    "Origin",
    "Access-Control-Request-Headers",
    "Access-Control-Request-Method",
    "User-Agent",
    "X-Forwarded-For",
    "Referer",
  ]
}