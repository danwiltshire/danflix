variable "application_name" {
  description = "The application name"
  type        = string

  validation {
    condition     = length(var.application_name) > 1
    error_message = "The value must be greater than 1 characters long."
  }
}

variable "aws_provider_configuration" {
  type = map(object({
    region = string
  }))
}

variable "auth0_provider_configuration" {
  type = map(object({
    auth0_domain        = string
    auth0_client_id     = string
    auth0_client_secret = string
  }))
}

variable "auth_allowed_domains" {
  type = list
}

variable "cloudfront_access_key_id" {}
variable "cloudfront_private_key" {}
variable "cloudfront_cookie_validity_hours" {}
