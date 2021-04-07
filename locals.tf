locals {
  config_bucket_name = var.enable_config ? "${var.bucket_name}-config" : null
  lambdas = concat(
    (null != var.lambdas) ? var.lambdas : [],
    var.enable_next_edge ? [
      {event_type = "origin-request", lambda_arn = module.lambda-next-edge[0].qualified_arn, include_body = true},
    ] : [],
    !var.enable_next_edge ? [
      {event_type = "origin-request", lambda_arn = module.lambda-proxy[0].qualified_arn, include_body = false},
    ] : [],
  )
  lambda_proxy_name                  = (null != var.lambda_proxy_name) ? var.lambda_proxy_name : "${replace(var.dns, ".", "-")}-proxy"
  lambda_next_edge_name              = (null != var.lambda_next_edge_name) ? var.lambda_next_edge_name : "${replace(var.dns, ".", "-")}-next-edge"
  lambda_next_edge_runtime           = (null != var.next_edge_runtime) ? var.next_edge_runtime : var.runtime
  lambda_next_edge_handler           = (null != var.next_edge_handler) ? var.next_edge_handler : var.handler
  lambda_next_edge_package_file      = (null != var.next_edge_package_file) ? var.next_edge_package_file : var.package_file
  lambda_next_edge_timeout           = (null != var.next_edge_timeout) ? var.next_edge_timeout : var.timeout
  lambda_next_edge_memory_size       = (null != var.next_edge_memory_size) ? var.next_edge_memory_size : var.memory_size
  lambda_next_edge_policy_statements = concat(var.policy_statements, var.next_edge_policy_statements)
  lambda_dynamics_name               = (null != var.lambda_dynamics_name) ? var.lambda_dynamics_name : "${replace(var.dns, ".", "-")}-dynamics"
  lambda_dynamics_runtime            = (null != var.dynamics_runtime) ? var.dynamics_runtime : var.runtime
  lambda_dynamics_handler            = (null != var.dynamics_handler) ? var.dynamics_handler : var.handler
  lambda_dynamics_package_file       = (null != var.dynamics_package_file) ? var.dynamics_package_file : var.package_file
  lambda_dynamics_timeout            = (null != var.dynamics_timeout) ? var.dynamics_timeout : var.timeout
  lambda_dynamics_memory_size        = (null != var.dynamics_memory_size) ? var.dynamics_memory_size : var.memory_size
  lambda_dynamics_policy_statements  = concat(var.policy_statements, var.dynamics_policy_statements)
  lambda_dynamics_variables          = merge(var.variables, var.dynamics_variables)
  lambda_api_name                    = (null != var.lambda_api_name) ? var.lambda_api_name : "${replace(var.dns, ".", "-")}-api"
  lambda_api_runtime                 = (null != var.api_runtime) ? var.api_runtime : var.runtime
  lambda_api_handler                 = (null != var.api_handler) ? var.api_handler : var.handler
  lambda_api_package_file            = (null != var.api_package_file) ? var.api_package_file : var.package_file
  lambda_api_timeout                 = (null != var.api_timeout) ? var.api_timeout : var.timeout
  lambda_api_memory_size             = (null != var.dynamics_memory_size) ? var.dynamics_memory_size : var.memory_size
  lambda_api_policy_statements       = concat(var.policy_statements, var.api_policy_statements)
  lambda_api_variables               = merge(var.variables, var.api_variables)
}

locals {
  config_url   = var.enable_config ? "https://${module.config[0].dns}/proxy.json" : null
  dynamics_dns = var.enable_dynamics ? module.api-dynamics[0].dns : null
  api_dns      = var.enable_api ? module.api-api[0].dns : null
}