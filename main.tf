module "https-cert" {
  source    = "./modules/https-cert"
  dns       = var.dns
  zone      = var.dns_zone
  providers = {
    aws     = aws
    aws.acm = aws.acm
  }
}

module "cdn" {
  source               = "./modules/cdn"
  dns                  = var.dns
  zone                 = var.dns_zone
  certificate_arn      = module.https-cert.certificate_arn
  geolocations         = var.geolocations
  apex_redirect        = var.apex_redirect
  price_class          = var.price_class
  redirect_config_file = var.redirect_config_file
  security_config_file = var.security_config_file
  name                 = var.name
  custom_behaviors     = var.custom_behaviors
  providers            = {
    aws = aws
  }
}