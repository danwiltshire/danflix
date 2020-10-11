variable "jwt_authorizer_issuer_url" {
  description = "The JWT authorizer issuer URL"
  type        = map(string)
}

variable "auth0_provider_config" {
  description = "Terraform Auth0 provider configuration"
  type        = map(string)
}
