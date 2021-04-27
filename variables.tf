variable "name" {
  type    = string
  default = "front"
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
variable "custom_behaviors" {
  type    = list(any)
  default = null
}
variable "price_class" {
  type    = string
  default = "PriceClass_100"
}
variable "redirect_config_file" {
  type    = string
  default = null
}
variable "security_config_file" {
  type    = string
  default = null
}
variable "regional_next_apps" {
  type    = map(string)
  default = {}
}
variable "regional_statics_buckets" {
  type = map(object({
    arn  = string
    name = string
  }))
  default = {}
}
variable "s3_master_domain_name" {
  type = string
}