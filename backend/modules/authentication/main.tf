terraform {
  required_providers {
    auth0 = {
      source  = "alexkappa/auth0"
      version = "> 0.8"
    }
  }
}

provider "auth0" {
  domain        = var.auth0_provider_config["domain"]
  client_id     = var.auth0_client_id
  client_secret = var.auth0_provider_config["client_secret"]
}

resource "auth0_resource_server" "danflix-auth0-api" {
  name                                            = "danflix-${terraform.workspace}-api"
  identifier                                      = var.auth0_identifier
  signing_alg                                     = "RS256"
  skip_consent_for_verifiable_first_party_clients = true
}

# The frontend React app uses this as an issuer
resource "auth0_client" "danflix-auth0-app" {
  name                       = "danflix-${terraform.workspace}-app"
  description                = "Danflix React application"
  app_type                   = "spa"
  oidc_conformant            = true
  token_endpoint_auth_method = "none"
  callbacks                  = var.auth0_callbacks
  web_origins                = var.auth0_allowed_web_origins
  allowed_logout_urls        = var.auth0_allowed_logout_urls
  jwt_configuration {
    alg                 = "RS256"
    lifetime_in_seconds = 36000
  }
}

# https://auth0.com/blog/use-terraform-to-manage-your-auth0-configuration/
/* resource "auth0_client" "terraform-secure-express" {
  name            = "Terraform Secure Express"
  app_type        = "regular_web"
  description     = "App for running Dockerized Express application via Terraform"
  callbacks       = ["http://localhost:3000/callback"]
  oidc_conformant = true

  jwt_configuration {
    alg = "RS256"
  }
} */