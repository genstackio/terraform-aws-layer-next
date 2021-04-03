variable "name" {
  type    = string
  default = "front"
}
variable "bucket_name" {
  type = string
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
variable "forwarded_headers" {
  type    = list(string)
  default = null
}
variable "lambda_proxy_name" {
  type    = string
  default = null
}