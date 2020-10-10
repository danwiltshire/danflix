output "api_invoke_url" {
  value = aws_apigatewayv2_stage.danflix-api-stage-default.invoke_url
}

output "cloudfront_distribution_domain" {
  value = aws_cloudfront_distribution.danflix-cloudfront-frontend.domain_name
}

output "auth0_app_client_id" {
  value = auth0_client.danflix-auth0-app.client_id
}
