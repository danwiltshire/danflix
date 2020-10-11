variable "jwt_authorizer_issuer_url" {
  description = "The JWT authorizer issuer URL"
  type        = map(string)
}

variable "auth0_provider_config" {
  description = "Terraform Auth0 provider configuration"
  type        = map(string)
}

variable "aws_provider_config" {
  description = "Terraform AWS provider configuration"
  type        = map(string)
}

variable "environment" {
  description = "The environment variable will be used in all supported resource names"
  type        = string

  validation {
    condition     = length(var.environment) > 1
    error_message = "The environment value must be greater than 1 characters long."
  }
}