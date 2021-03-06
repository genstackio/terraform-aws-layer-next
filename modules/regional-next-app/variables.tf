variable "name" {
  type    = string
  default = "next"
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
variable "variables" {
  type    = map(string)
  default = {}
}
variable "package_file" {
  type    = string
  default = null
}
variable "memory_size" {
  type    = number
  default = 1024
}
variable "timeout" {
  type    = number
  default = 30
}
variable "handler" {
  type    = string
  default = "node_modules/@ohoareau/aws-lambda-next/lib/index.handler"
}
variable "runtime" {
  type    = string
  default = "nodejs12.x"
}