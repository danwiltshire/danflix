output "private_storage_media_id" {
  value = module.private_storage_media.id
}

output "private_storage_webapp_id" {
  value = module.private_storage_webapp.id
}

output "iam_role_policy_getsignedcookie_role_name" {
  value = module.iam_role_policy_getsignedcookie.role_name
}

output "iam_role_policy_getsignedcookie_policy_name" {
  value = module.iam_role_policy_getsignedcookie.policy_name
}

output "function_getsignedcookie_name" {
  value = module.function_getsignedcookie.function_name
}

output "api_name" {
  value = aws_apigatewayv2_api.api.name
}

output "api_endpoint" {
  value = aws_apigatewayv2_api.api.api_endpoint
}

output "cloudfront_distribution_domain_name" {
  value = aws_cloudfront_distribution.this.domain_name
}

output "auth_client_id" {
  value = module.auth_app.client_id
}

output "auth_domain" {
  value = var.auth0_provider_configuration[terraform.workspace]["auth0_domain"]
}
