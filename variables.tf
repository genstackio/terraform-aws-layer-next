variable "name" {
  type    = string
  default = "front"
}
variable "bucket_name" {
  type = string
}
variable "enable_config" {
  type    = bool
  default = false
}
variable "enable_statics" {
  type    = bool
  default = true
}
variable "enable_optimized_statics" {
  type    = bool
  default = false
}
variable "enable_dynamics" {
  type    = bool
  default = false
}
variable "enable_api" {
  type    = bool
  default = false
}
variable "geolocations" {
  type    = list(string)
  default = []
}
variable "dns" {
  type = string
}
variable "dns_zone" {
  type = string
}
variable "apex_redirect" {
  type    = bool
  default = false
}
variable "lambdas" {
  type    = list(any)
  default = null
}
variable "lambda_proxy_name" {
  type    = string
  default = null
}
variable "lambda_dynamics_name" {
  type    = string
  default = null
}
variable "lambda_api_name" {
  type    = string
  default = null
}
variable "log_group_regions" {
  type    = list(string)
  default = []
}
variable "policy_statements" {
  type = list(
  object({
    actions   = list(string),
    resources = list(string),
    effect    = string
  })
  )
  default = []
}
variable "dynamics_policy_statements" {
  type = list(
  object({
    actions   = list(string),
    resources = list(string),
    effect    = string
  })
  )
  default = []
}
variable "api_policy_statements" {
  type = list(
  object({
    actions   = list(string),
    resources = list(string),
    effect    = string
  })
  )
  default = []
}
variable "variables" {
  type    = map(string)
  default = {}
}
variable "dynamics_variables" {
  type    = map(string)
  default = {}
}
variable "api_variables" {
  type    = map(string)
  default = {}
}
variable "package_file" {
  type    = string
  default = null
}
variable "dynamics_package_file" {
  type    = string
  default = null
}
variable "api_package_file" {
  type    = string
  default = null
}
variable "memory_size" {
  type    = number
  default = 1024
}
variable "dynamics_memory_size" {
  type    = number
  default = null
}
variable "api_memory_size" {
  type    = number
  default = null
}
variable "timeout" {
  type    = number
  default = 30
}
variable "dynamics_timeout" {
  type    = number
  default = null
}
variable "api_timeout" {
  type    = number
  default = null
}
variable "handler" {
  type    = string
  default = "node_modules/@ohoareau/aws-apigw-next/lib/index.handler"
}
variable "dynamics_handler" {
  type    = string
  default = null
}
variable "api_handler" {
  type    = string
  default = null
}
variable "debug" {
  type    = bool
  default = false
}
variable "custom_behaviors" {
  type    = list(any)
  default = null
}