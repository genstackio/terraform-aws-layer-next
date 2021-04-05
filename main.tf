module "website" {
  source                = "genstackio/website/aws"
  version               = "0.1.39"
  name                  = var.name
  bucket_name           = var.bucket_name
  zone                  = var.dns_zone
  dns                   = var.dns
  geolocations          = var.geolocations
  forward_query_string  = true
  forwarded_headers     = ["*"]
  apex_redirect         = var.apex_redirect
  lambdas               = local.lambdas
  custom_origin_headers = concat(
    [{name = "X-Forwarded-For", value = var.dns}],
    var.enable_config ? [{name = "X-CloudFront-Edge-Next-Config-Url", value = local.config_url}] : [],
    var.enable_dynamics ? [{name = "X-CloudFront-Edge-Next-Dynamics-DNS", value = local.dynamics_dns}] : [],
    var.enable_api ? [{name = "X-CloudFront-Edge-Next-Api-DNS", value = local.api_dns}] : [],
    var.enable_statics ? [{name = "X-CloudFront-Edge-Next-Statics", value = "1"}] : [],
  )
  providers             = {
    aws     = aws
    aws.acm = aws.acm
  }
}
module "config" {
  count       = var.enable_config ? 1 : 0
  source      = "genstackio/website/aws//modules/private-website"
  version     = "0.1.39"
  name        = var.name
  bucket_name = local.config_bucket_name
  providers = {
    aws = aws
  }
}

module "lambda-proxy" {
  source            = "genstackio/website/aws//modules/lambda-proxy"
  version           = "0.1.39"
  name              = local.lambda_proxy_name
  config_file       = "${path.module}/config.js"
  log_group_regions = var.log_group_regions
  providers         = {
    aws = aws
  }
}
module "lambda-dynamics" {
  count             = var.enable_dynamics ? 1 : 0
  source            = "genstackio/lambda/aws"
  version           = "0.1.8"
  file              = local.lambda_dynamics_package_file
  name              = local.lambda_dynamics_name
  handler           = local.lambda_dynamics_handler
  timeout           = local.lambda_dynamics_timeout
  memory_size       = local.lambda_dynamics_memory_size
  policy_statements = local.lambda_dynamics_policy_statements
  variables         = local.lambda_dynamics_variables
  providers         = {
    aws = aws
  }
}
module "lambda-api" {
  count             = var.enable_api ? 1 : 0
  source            = "genstackio/lambda/aws"
  version           = "0.1.8"
  file              = local.lambda_api_package_file
  name              = local.lambda_api_name
  handler           = local.lambda_api_handler
  timeout           = local.lambda_api_timeout
  memory_size       = local.lambda_api_memory_size
  policy_statements = local.lambda_api_policy_statements
  variables         = local.lambda_api_variables
  providers         = {
    aws = aws
  }
}

module "api-dynamics" {
  count      = var.enable_dynamics ? 1 : 0
  source     = "genstackio/apigateway2-api/aws"
  version    = "0.1.3"
  name       = local.lambda_dynamics_name
  lambda_arn = var.enable_dynamics ? module.lambda-dynamics[0].arn : null
  providers  = {
    aws = aws
  }
}
module "api-api" {
  count      = var.enable_api ? 1 : 0
  source     = "genstackio/apigateway2-api/aws"
  version    = "0.1.3"
  name       = local.lambda_api_name
  lambda_arn = var.enable_api ? module.lambda-api[0].arn : null
  providers  = {
    aws = aws
  }
}