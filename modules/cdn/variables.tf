variable "name" {
  type    = string
  default = "front"
}
variable "dns" {
  type = string
}
variable "zone" {
  type = string
}
variable "apex_redirect" {
  type    = bool
  default = false
}
variable "certificate_arn" {
  type = string
}
variable "geolocations" {
  type    = list(string)
  default = []
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
variable "custom_behaviors" {
  type    = list(any)
  default = null
}