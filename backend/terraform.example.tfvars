jwt_authorizer_issuer_url = {
  prod = "https://domain.auth0.com/"
}

auth0_provider_config = {
  domain        = "auth0.com"
  client_id     = "abc"
  client_secret = "abc123"
}

aws_provider_config = {
  access_key = "abc"
  secret_key = "abc123"
}

environment = "prod"

// TODO: cleaner 
/*provider_configuration = {
    "prod" = {
        "aws" = {
            access_key = "abc"
            secret_key = "abc123"
        },
        "auth0" = {
            domain        = "auth0.com"
            client_id     = "abc"
            client_secret = "abc123"
        }
    }
    "dev" = {
        "aws" = {
            access_key = "abc"
            secret_key = "abc123"
        },
        "auth0" = {
            domain        = "auth0.com"
            client_id     = "abc"
            client_secret = "abc123"
        }
    }
}*/
