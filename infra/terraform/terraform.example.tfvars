application_name = "danflix"

aws_provider_configuration = {
  prod = {
    region = "eu-west-2"
  }
  dev = {
    region = "eu-west-2"
  }
  test = {
    region = "eu-west-2"
  }
}

auth0_provider_configuration = {
  prod = {
    auth0_domain        = "tenant.eu.auth0.com"
    auth0_client_id     = "abc"
    auth0_client_secret = "abc123"
  }
  dev = {
    auth0_domain        = "tenant.eu.auth0.com"
    auth0_client_id     = "abc"
    auth0_client_secret = "abc123"
  }
  test = {
    auth0_domain        = "tenant.eu.auth0.com"
    auth0_client_id     = "abc"
    auth0_client_secret = "abc123"
  }
}

auth_allowed_domains = ["domain.com", "domain2.com"]

cloudfront_cookie_validity_hours = 24
cloudfront_access_key_id         = "ABCDEFGHIJKLMNOPQRSTUVWYZ"
cloudfront_private_key           = <<EOF
privatekeyprivatekeyprivatekeyprivatekeyprivatekeyprivatekeypriv
privatekeyprivatekeyprivatekeyprivatekeyprivatekeyprivatekeypriv
privatekeyprivatekeyprivatekeyprivatekeyprivatekeyprivatekeypriv
privatekeyprivatekeyprivatekeyprivatekeyprivatekeyprivatekeypriv
privatekeyprivatekeyprivatekeyprivatekeyprivatekeyprivatekeypriv
privatekeyprivatekeyprivatekeyprivatekeyprivatekeyprivatekeypriv
privatekeyprivatekeyprivatekeyprivatekeyprivatekeyprivatekeypriv
privatekeyprivatekeyprivatekeyprivatekeyprivatekeyprivatekeypriv
privatekeyprivatekeyprivatekeyprivatekeyprivatekeyprivatekeypriv
privatekeyprivatekeyprivatekeyprivatekeyprivatekeyprivatekeypriv
privatekeyprivatekeyprivatekeyprivatekeyprivatekeyprivatekeypriv
privatekeyprivatekeyprivatekeyprivatekeyprivatekeyprivatekeypriv
privatekeyprivatekeyprivatekeyprivatekeyprivatekeyprivatekeypriv
privatekeyprivatekeyprivatekeyprivatekeyprivatekeyprivatekeypriv
privatekeyprivatekeyprivatekeyprivatekeyprivatekeyprivatekeypriv
privatekeyprivatekeyprivatekeyprivatekeyprivatekeyprivatekeypriv
privatekeyprivatekeyprivatekeyprivatekeyprivatekeyprivatekeypriv
privatekeyprivatekeyprivatekeyprivatekeyprivatekeyprivatekeypriv
privatekeyprivatekeyprivatekeyprivatekeyprivatekeyprivatekeypriv
privatekeyprivatekeyprivatekeyprivatekeyprivatekeyprivatekeypriv
privatekeyprivatekeyprivatekeyprivatekeyprivatekeyprivatekeypriv
privatekeyprivatekeyprivatekeyprivatekeyprivatekeyprivatekeypriv
privatekeyprivatekeyprivatekeyprivatekeyprivatekeyprivatekeypriv
privatekeyprivatekeyprivatekeyprivatekeyprivatekeypri
EOF
