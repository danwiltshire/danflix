resource "aws_apigatewayv2_integration" "this" {
  api_id             = var.api_id
  integration_type   = var.integration_type
  integration_method = var.integration_method
  integration_uri    = var.integration_uri
}
