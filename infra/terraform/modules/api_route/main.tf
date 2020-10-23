resource "aws_apigatewayv2_route" "this" {
  api_id             = var.api_id
  route_key          = var.route_key
  target             = var.target
  authorization_type = var.authorization_type
  authorizer_id      = var.authorizer_id
}
