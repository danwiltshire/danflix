# The AWS API gateway verifies JWT tokens using this
resource "auth0_resource_server" "this" {
  name                                            = var.name
  identifier                                      = var.identifier
  signing_alg                                     = var.signing_alg
  skip_consent_for_verifiable_first_party_clients = var.skip_consent
}
