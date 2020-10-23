# The frontend React app uses this as an issuer
resource "auth0_client" "this" {
  name                       = var.name
  description                = var.description
  app_type                   = var.type
  oidc_conformant            = var.oidc_conformant
  token_endpoint_auth_method = var.token_endpoint_auth_method
  callbacks                  = var.callbacks
  web_origins                = var.allowed_web_origins
  allowed_logout_urls        = var.allowed_logout_urls
  jwt_configuration {
    alg                 = var.jwt_alg
    lifetime_in_seconds = var.jwt_lifetime_in_seconds
  }
}
