variable "environment" {
  description = "The environment such as prod or dev"
  type        = string
}

variable "authorizer_issuer_url" {
  description = "The JWT authorizer issuer URL"
  type        = string
}