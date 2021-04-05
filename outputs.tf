output "dns" {
  value = module.website.dns
}
output "cloudfront_id" {
  value = module.website.cloudfront_id
}
output "config_cloudfront_id" {
  value = var.enable_config ? module.config[0].cloudfront_id : null
}
output "statics_bucket_name" {
  value = var.enable_statics ? module.website.bucket_name : null
}
output "statics_bucket_arn" {
  value = var.enable_statics ? module.website.bucket_arn : null
}
output "statics_bucket_id" {
  value = var.enable_statics ? module.website.bucket_id : null
}
output "lambda_proxy_arn" {
  value = module.lambda-proxy.arn
}
output "lambda_proxy_qualified_arn" {
  value = module.lambda-proxy.qualified_arn
}
output "lambda_proxy_invoke_arn" {
  value = module.lambda-proxy.invoke_arn
}
output "lambda_proxy_name" {
  value = module.lambda-proxy.name
}
output "lambda_proxy_role_name" {
  value = module.lambda-proxy.role_name
}
output "lambda_dynamics_arn" {
  value = var.enable_dynamics ? module.lambda-dynamics[0].arn : null
}
output "lambda_dynamics_invoke_arn" {
  value = var.enable_dynamics ? module.lambda-dynamics[0].invoke_arn : null
}
output "lambda_dynamics_name" {
  value = var.enable_dynamics ? module.lambda-dynamics[0].name : null
}
output "lambda_dynamics_role_name" {
  value = var.enable_dynamics ? module.lambda-dynamics[0].role_name : null
}
output "lambda_api_arn" {
  value = var.enable_api ? module.lambda-api[0].arn : null
}
output "lambda_api_invoke_arn" {
  value = var.enable_api ? module.lambda-api[0].invoke_arn : null
}
output "lambda_api_name" {
  value = var.enable_api ? module.lambda-api[0].name : null
}
output "lambda_api_role_name" {
  value = var.enable_api ? module.lambda-api[0].role_name : null
}
