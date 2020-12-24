output "api_invoke_url" {
  value = aws_apigatewayv2_stage.danflix-api-stage-default.invoke_url
}

output "cloudfront_distribution_domain" {
  value = aws_cloudfront_distribution.danflix-cloudfront-frontend.domain_name
}

output "auth0_app_client_id" {
  value = module.authentication.auth0_app_client_id
}

output "auth0_app_client_secret" {
  value = module.authentication.auth0_app_client_secret
}
