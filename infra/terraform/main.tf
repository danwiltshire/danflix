provider "aws" {
  profile = terraform.workspace
  // Specify region because Terraform ignores region in ~/.aws/config
  region = var.aws_provider_configuration[terraform.workspace]["region"]
}

provider "auth0" {
  domain        = var.auth0_provider_configuration[terraform.workspace]["auth0_domain"]
  client_id     = var.auth0_provider_configuration[terraform.workspace]["auth0_client_id"]
  client_secret = var.auth0_provider_configuration[terraform.workspace]["auth0_client_secret"]
}

terraform {
  backend "s3" {}
}

locals {
  resource_prefix = "${var.application_name}-${terraform.workspace}"
}

/**
 * # get details about the AWS account
*/
data "aws_caller_identity" "this" {
  provider = aws
}

/**
 * # webapp S3 bucket
*/
module "private_storage_webapp" {
  source       = "./modules/private_storage"
  storage_name = "${local.resource_prefix}-webapp"
  policy = templatefile("./modules/private_storage/templates/allow_cloudfront.json.tmpl", {
    cloudfront_oai_arn = aws_cloudfront_origin_access_identity.storage_webapp.iam_arn
    bucket_name        = "${local.resource_prefix}-webapp"
  })
}

/**
 * # media S3 bucket
*/
module "private_storage_media" {
  source       = "./modules/private_storage"
  storage_name = "${local.resource_prefix}-media"
  policy = templatefile("./modules/private_storage/templates/allow_cloudfront.json.tmpl", {
    cloudfront_oai_arn = aws_cloudfront_origin_access_identity.storage_media.iam_arn
    bucket_name        = "${local.resource_prefix}-media"
  })
}

/**
 * # secret to hold cloudfront private key
*/
resource "aws_secretsmanager_secret" "this" {
  name                    = "${local.resource_prefix}-cloudfront-private-key"
  recovery_window_in_days = 0
}

/**
 * # secret value
*/
resource "aws_secretsmanager_secret_version" "this" {
  secret_id     = aws_secretsmanager_secret.this.id
  secret_string = var.cloudfront_private_key
}

/**
 * # getsignedcookie lambda IAM role
*/
module "iam_role_policy_getsignedcookie" {
  source        = "./modules/iam_role_policy"
  role_name     = "${local.resource_prefix}-allow-getsignedcookie"
  role_template = file("./modules/iam_role_policy/templates/allow_lambda_assume.json")
  policy_name   = "${local.resource_prefix}-allow-getsignedcookie"
  policy_template = templatefile("./modules/iam_role_policy/templates/allow_getsignedcookie.json.tmpl", {
    region                   = var.aws_provider_configuration[terraform.workspace]["region"]
    account_id               = data.aws_caller_identity.this.account_id
    cloudfront_access_key_id = var.cloudfront_access_key_id
    secret_value_arn         = aws_secretsmanager_secret_version.this.arn
  })
}

/**
 * # getsignedcookie lambda function
*/
module "function_getsignedcookie" {
  source          = "./modules/function"
  function_name   = "${local.resource_prefix}-getsignedcookie"
  handler         = "index.handler"
  runtime         = "nodejs12.x"
  role_arn        = module.iam_role_policy_getsignedcookie.role_arn
  lambda_template = file("./modules/function/templates/getsignedcookie.js.tmpl")
  lambda_env_vars = {
    REGION         = var.aws_provider_configuration[terraform.workspace]["region"]
    SECRET_NAME    = aws_secretsmanager_secret.this.name
    CLOUDFRONT_URL = "https://${aws_cloudfront_distribution.this.domain_name}"
    CLOUDFRONT_COOKIE_VALIDITY_HOURS = var.cloudfront_cookie_validity_hours
    ACCESS_KEY_ID  = var.cloudfront_access_key_id
  }
}

/**
 * # allow calling getsignedcookie function from API gateway
*/
resource "aws_lambda_permission" "function_getsignedcookie_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = module.function_getsignedcookie.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}

/**
 * # API gateway
*/
resource "aws_apigatewayv2_api" "api" {
  name          = "${local.resource_prefix}-api"
  protocol_type = "HTTP"
  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET", "OPTIONS"]
    allow_headers = ["authorization"]
  }
}

/**
 * # API gateway integrations
*/
module "api_integration_getsignedcookie" {
  source             = "./modules/api_integration"
  api_id             = aws_apigatewayv2_api.api.id
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
  integration_uri    = module.function_getsignedcookie.invoke_arn
}

/**
 * # API gateway routes
*/
module "api_route_api" {
  source             = "./modules/api_route"
  api_id             = aws_apigatewayv2_api.api.id
  route_key          = "GET /api"
  target             = null
  authorization_type = null
  authorizer_id      = null
}
module "api_route_api_get_getsignedcookie" {
  source             = "./modules/api_route"
  api_id             = aws_apigatewayv2_api.api.id
  route_key          = "GET /api/signedcookie"
  target             = "integrations/${module.api_integration_getsignedcookie.id}"
  authorization_type = "JWT"
  authorizer_id      = module.api_authorizer.id
}
module "api_route_api_options_getsignedcookie" {
  source             = "./modules/api_route"
  api_id             = aws_apigatewayv2_api.api.id
  route_key          = "OPTIONS /api/signedcookie"
  target             = null
  authorization_type = null
  authorizer_id      = null
}

/**
 * # API gateway authorizers
*/
module "api_authorizer" {
  source           = "./modules/api_authorizer"
  api_id           = aws_apigatewayv2_api.api.id
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]
  name             = "${local.resource_prefix}-authorizer"
  jwt_audience     = [aws_apigatewayv2_api.api.api_endpoint]
  jwt_issuer       = "https://${var.auth0_provider_configuration[terraform.workspace]["auth0_domain"]}/"
}

/**
 * # API gateway default stage
*/
resource "aws_apigatewayv2_stage" "api_stage" {
  api_id      = aws_apigatewayv2_api.api.id
  name        = "$default"
  auto_deploy = true
  default_route_settings {
    throttling_burst_limit = 10
    throttling_rate_limit  = 5
  }
}

/**
 * # Auth0 api for use by AWS API Gateway
*/
module "auth_api" {
  source       = "./modules/auth_api"
  name         = "${local.resource_prefix}-api"
  identifier   = aws_apigatewayv2_api.api.api_endpoint

  signing_alg  = "RS256"
  skip_consent = true
}

/**
 * # Auth0 app for use by webapp
*/
module "auth_app" {
  source                     = "./modules/auth_app"
  name                       = "${local.resource_prefix}-app"
  description                = "Authentication for webapp"
  type                       = "spa"
  oidc_conformant            = true
  token_endpoint_auth_method = "none"
  callbacks                  = ["https://${aws_cloudfront_distribution.this.domain_name}"]
  allowed_web_origins        = ["https://${aws_cloudfront_distribution.this.domain_name}"]
  allowed_logout_urls        = ["https://${aws_cloudfront_distribution.this.domain_name}"]
  jwt_alg                    = "RS256"
  jwt_lifetime_in_seconds    = 36000
}

/**
 * # Auth0 domain whitelist rule
*/
module "auth_rule_allowed_domains" {
  source = "./modules/auth_rule"
  name   = "${local.resource_prefix}-domain-whitelist"
  script = templatefile("./modules/auth_rule/templates/rule_allowed_domains.js.tmpl", {
    auth_allowed_domains = var.auth_allowed_domains
  })
  enabled = true
}

/**
 * # OAI used as part of Bucket policy to allow access from CloudFront
*/
resource "aws_cloudfront_origin_access_identity" "storage_media" {
  comment = "${local.resource_prefix}-oai-storage-media"
}
resource "aws_cloudfront_origin_access_identity" "storage_webapp" {
  comment = "${local.resource_prefix}-oai-storage-webapp"
}

/**
 * # CloudFront CDN distribution
*/
resource "aws_cloudfront_distribution" "this" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  price_class         = "PriceClass_100"
  /**
   * ## Default route goes to the webapp
  */
  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = module.private_storage_webapp.id
    compress               = "false"
    viewer_protocol_policy = "https-only"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
    forwarded_values {
      query_string = false
      cookies { forward = "none" }
    }
  }
  /**
   * ## Route to API
  */
  ordered_cache_behavior {
    path_pattern           = "api/*"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"] // OPTIONS for CORS
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "${local.resource_prefix}-api"
    compress               = "false"
    viewer_protocol_policy = "https-only"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
    forwarded_values {
      query_string = false
      headers = ["Authorization"] // Required for Auth0 bearer token
      cookies {
        forward = "whitelist" 
        whitelisted_names = [ // Generated cookies by getsignedcookies lambda
          "CloudFront-Policy",
          "CloudFront-Key-Pair-Id",
          "CloudFront-Signature"
        ]
      }
    }
  }
  /**
   * ## Route to media
  */
  ordered_cache_behavior {
    path_pattern           = "media/*"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = module.private_storage_media.id
    compress               = "false"
    viewer_protocol_policy = "https-only"
    trusted_signers        = ["self"] // Require signed cookies
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
    forwarded_values {
      query_string = false
      cookies { forward = "none" }
    }
  }
  origin {
    domain_name = module.private_storage_webapp.bucket_regional_domain_name
    origin_id   = module.private_storage_webapp.id
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.storage_webapp.cloudfront_access_identity_path
    }
  }
  origin {
    domain_name = module.private_storage_media.bucket_regional_domain_name
    origin_id   = module.private_storage_media.id
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.storage_media.cloudfront_access_identity_path
    }
  }
  origin {
    domain_name = trimprefix(aws_apigatewayv2_api.api.api_endpoint, "https://")
    origin_id   = "${local.resource_prefix}-api"
    custom_origin_config {
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
