variable "jwt_authorizer_issuer_url" {
  description = "The JWT authorizer issuer URL"
  type        = map(string)
}

variable "terraform_auth0_provider" {
  description = "Terraform Auth0 provider configuration"
  type        = map(string)
}
