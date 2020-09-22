variable "environment" {
  description = "The environment such as prod or dev"
  type        = string
}

variable "authorizer_issuer_url" {
  description = "The JWT authorizer issuer URL"
  type        = string
}

variable "auth0_domain" {
  description = "Your Auth0 domain name"
  type        = string
}

variable "auth0_client_id" {
  description = "Your Auth0 client ID"
  type        = string
}

variable "auth0_client_secret" {
  description = "Your Auth0 client secret"
  type        = string
}
