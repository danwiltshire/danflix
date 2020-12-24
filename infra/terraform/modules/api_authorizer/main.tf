resource "aws_apigatewayv2_authorizer" "this" {
  api_id           = var.api_id
  authorizer_type  = var.authorizer_type
  identity_sources = var.identity_sources
  name             = var.name

  jwt_configuration {
    audience = var.jwt_audience
    issuer   = var.jwt_issuer
  }
}
