variable "auth0_provider_configuration" {
  type = map(object({
    auth0_domain        = string
    auth0_client_id     = string
    auth0_client_secret = string
  }))
}

variable "aws_provider_configuration" {
  type = map(object({
    aws_access_key = string
    aws_secret_key = string
  }))
}

variable "environment" {
  description = "The environment variable will be used in all supported resource names"
  type        = string

  validation {
    condition     = length(var.environment) > 1
    error_message = "The environment value must be greater than 1 characters long."
  }
}