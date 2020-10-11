provider "aws" {
  profile    = "default"
  region     = "eu-west-2"
  access_key = var.aws_provider_config.access_key
  secret_key = var.aws_provider_config.secret_key
}

provider "auth0" {
  domain        = var.auth0_provider_config["domain"]
  client_id     = var.auth0_provider_config["client_id"]
  client_secret = var.auth0_provider_config["client_secret"]
}

module "authentication" {
  source = "./modules/authentication"

  /*  auth0_allowed_logout_urls = var.auth0_allowed_logout_urls
  auth0_allowed_web_origins = var.auth0_allowed_web_origins
  auth0_callbacks = var.auth0_callbacks
  auth0_identifier = var.auth0_identifier*/

  auth0_allowed_logout_urls = ["https://${aws_cloudfront_distribution.danflix-cloudfront-frontend.domain_name}", "http://localhost:3000"]
  auth0_allowed_web_origins = ["https://${aws_cloudfront_distribution.danflix-cloudfront-frontend.domain_name}", "http://localhost:3000"]
  auth0_callbacks           = ["https://${aws_cloudfront_distribution.danflix-cloudfront-frontend.domain_name}", "http://localhost:3000"]
  auth0_identifier          = aws_apigatewayv2_stage.danflix-api-stage-default.invoke_url
}

resource "aws_resourcegroups_group" "danflix-rg" {
  name = "danflix-${terraform.workspace}"

  resource_query {
    query = <<JSON
{
"ResourceTypeFilters":
  [ "AWS::AllSupported" ],
"TagFilters":
  [
    {
      "Key": "Environment",
      "Values": ["${terraform.workspace}"]
    }
  ]
}
  JSON
  }
}

# TODO: See aws_iam_policy_document for this.
resource "aws_iam_role" "danflix-iam-role-lambda" {
  name = "danflix-${terraform.workspace}-iam-role-lambda"

  assume_role_policy = <<-EOF
{
"Version": "2012-10-17",
"Statement":
  [
    {
    "Action": "sts:AssumeRole",
    "Principal": { "Service": "lambda.amazonaws.com" },
    "Effect": "Allow",
    "Sid": ""
    }
  ]
}
  EOF

  tags = {
    Environment = terraform.workspace
  }
}

# TODO: See aws_iam_policy_document for this.
resource "aws_iam_policy" "danflix-iam-policy-storage-media" {
  name = "danflix-${terraform.workspace}-iam-policy-storage-media"

  policy = <<EOF
{
"Version": "2012-10-17",
"Statement":
  [
    {
    "Sid": "ListObjectsInBucket",
    "Effect": "Allow",
    "Action": "s3:ListBucket",
    "Resource": [ "arn:aws:s3:::danflix-${terraform.workspace}-storage-media" ]
    },
    {
    "Sid": "GetObjectInBucket",
    "Effect": "Allow",
    "Action": "s3:GetObject",
    "Resource": [ "arn:aws:s3:::danflix-${terraform.workspace}-storage-media/*" ]
    },
    {
    "Effect": "Allow",
    "Action": [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ],
     "Resource": "*"
    }
  ]
}
  EOF
}

resource "aws_iam_role_policy_attachment" "danflix-iam-attach-lambda-storage" {
  role       = aws_iam_role.danflix-iam-role-lambda.name
  policy_arn = aws_iam_policy.danflix-iam-policy-storage-media.arn
}

resource "aws_s3_bucket" "danflix-storage-media" {
  bucket        = "danflix-${terraform.workspace}-storage-media"
  acl           = "private"
  force_destroy = true

  tags = {
    Environment = terraform.workspace
  }
}

resource "aws_s3_bucket" "danflix-storage-frontend" {
  bucket        = "danflix-${terraform.workspace}-storage-frontend"
  acl           = "private"
  force_destroy = true

  tags = {
    Environment = terraform.workspace
  }
}

data "aws_iam_policy_document" "danflix-iam-policy-storage-frontend" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.danflix-storage-frontend.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.danflix-cloudfront-frontend-origin_access_identity.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "danflix-storage-frontend-policy" {
  bucket = aws_s3_bucket.danflix-storage-frontend.id
  policy = data.aws_iam_policy_document.danflix-iam-policy-storage-frontend.json
}

resource "aws_cloudfront_origin_access_identity" "danflix-cloudfront-frontend-origin_access_identity" {
}

resource "aws_cloudfront_distribution" "danflix-cloudfront-frontend" {
  origin {
    domain_name = aws_s3_bucket.danflix-storage-frontend.bucket_regional_domain_name
    origin_id   = "danflix-${terraform.workspace}-storage-frontend"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.danflix-cloudfront-frontend-origin_access_identity.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "danflix-${terraform.workspace}-storage-frontend"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    compress               = "true"
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Environment = terraform.workspace
  }
}


# TODO: Need a better way of managing Lambda function code
data "archive_file" "danflix-lambda-code-get-presignedurl" {
  type        = "zip"
  output_path = "/tmp/danflix-lambda-code-get-presignedurl.zip"
  source {
    content  = <<EOF
const AWS = require('aws-sdk');
const s3 = new AWS.S3();

exports.handler = async (event) => {
  const url = await s3.getSignedUrlPromise('getObject', {
  Bucket: '${aws_s3_bucket.danflix-storage-media.id}',
  Key: 'index.html',
  Expires: 5,
  }).catch((err) => console.error(err));
  if ( url ) {
    const response = {
        statusCode: 200,
        body: url,
    };
    return response;
  }
}
EOF
    filename = "index.js"
  }
}

resource "aws_lambda_function" "danflix-lambda-function-get-presignedurl" {
  filename         = data.archive_file.danflix-lambda-code-get-presignedurl.output_path
  source_code_hash = data.archive_file.danflix-lambda-code-get-presignedurl.output_base64sha256
  function_name    = "danflix-${terraform.workspace}-lambda-function-get-presignedurl"
  role             = aws_iam_role.danflix-iam-role-lambda.arn
  handler          = "index.handler"
  runtime          = "nodejs12.x"

  tags = {
    Environment = terraform.workspace
  }
}

# Resolve 500 Server Error
resource "aws_lambda_permission" "danflix-lambda-policy-get-presignedurl" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.danflix-lambda-function-get-presignedurl.function_name
  principal     = "apigateway.amazonaws.com"

  # The /*/*/* part allows invocation from any stage, method and resource path
  # within API Gateway REST API. the last one indicates where to send requests to.
  # see more detail https://docs.aws.amazon.com/lambda/latest/dg/services-apigateway.html
  source_arn = "${aws_apigatewayv2_api.danflix-api.execution_arn}/*/*"
}

# TODO: Need a better way of managing Lambda function code
data "archive_file" "danflix-lambda-code-get-listobjects" {
  type        = "zip"
  output_path = "/tmp/danflix-lambda-code-get-listobjects.zip"
  source {
    content  = <<EOF
const AWS = require('aws-sdk');
const s3 = new AWS.S3({apiVersion: '2006-03-01'});

exports.handler = async (event, context) => {
    
    const res = await s3.listObjectsV2({
      Bucket: '${aws_s3_bucket.danflix-storage-media.id}'
    }).promise();
    
    const items = res.Contents.filter(item => item.Key.endsWith('.m3u8'));
    
    if ( items ) {
        return {
            statusCode: 200,
            body: JSON.stringify(items)
        }
    } else {
        return {
            statusCode: 404,
        }
    }
    
};

EOF
    filename = "index.js"
  }
}

resource "aws_lambda_function" "danflix-lambda-function-get-listobjects" {
  filename         = data.archive_file.danflix-lambda-code-get-listobjects.output_path
  source_code_hash = data.archive_file.danflix-lambda-code-get-listobjects.output_base64sha256
  function_name    = "danflix-${terraform.workspace}-lambda-function-get-listobjects"
  role             = aws_iam_role.danflix-iam-role-lambda.arn
  handler          = "index.handler"
  runtime          = "nodejs12.x"

  tags = {
    Environment = terraform.workspace
  }
}

# Resolve 500 Server Error
resource "aws_lambda_permission" "danflix-lambda-policy-get-list-objects" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.danflix-lambda-function-get-listobjects.function_name
  principal     = "apigateway.amazonaws.com"

  # The /*/*/* part allows invocation from any stage, method and resource path
  # within API Gateway REST API. the last one indicates where to send requests to.
  # see more detail https://docs.aws.amazon.com/lambda/latest/dg/services-apigateway.html
  source_arn = "${aws_apigatewayv2_api.danflix-api.execution_arn}/*/*"
}

resource "aws_apigatewayv2_api" "danflix-api" {
  name          = "danflix-${terraform.workspace}-api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["https://${aws_cloudfront_distribution.danflix-cloudfront-frontend.domain_name}", "http://localhost:3000"]
    allow_methods = ["GET"]
  }

  tags = {
    Environment = terraform.workspace
  }
}

resource "aws_apigatewayv2_route" "danflix-api-route-get-presignedurl" {
  api_id             = aws_apigatewayv2_api.danflix-api.id
  route_key          = "GET /presignedurl"
  target             = "integrations/${aws_apigatewayv2_integration.danflix-api-route-get-presignedurl-integration.id}"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.danflix-api-authorizer.id
}

resource "aws_apigatewayv2_integration" "danflix-api-route-get-presignedurl-integration" {
  api_id             = aws_apigatewayv2_api.danflix-api.id
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
  integration_uri    = aws_lambda_function.danflix-lambda-function-get-presignedurl.invoke_arn
}

resource "aws_apigatewayv2_route" "danflix-api-route-get-listobjects" {
  api_id             = aws_apigatewayv2_api.danflix-api.id
  route_key          = "GET /listobjects"
  target             = "integrations/${aws_apigatewayv2_integration.danflix-api-route-get-listobjects-integration.id}"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.danflix-api-authorizer.id
}

resource "aws_apigatewayv2_integration" "danflix-api-route-get-listobjects-integration" {
  api_id             = aws_apigatewayv2_api.danflix-api.id
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
  integration_uri    = aws_lambda_function.danflix-lambda-function-get-listobjects.invoke_arn
}

resource "aws_apigatewayv2_stage" "danflix-api-stage-default" {
  api_id      = aws_apigatewayv2_api.danflix-api.id
  name        = "$default"
  auto_deploy = true

  tags = {
    Environment = terraform.workspace
  }
}

resource "aws_apigatewayv2_authorizer" "danflix-api-authorizer" {
  api_id           = aws_apigatewayv2_api.danflix-api.id
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]
  name             = "danflix-${terraform.workspace}-authorizer"

  jwt_configuration {
    audience = [aws_apigatewayv2_stage.danflix-api-stage-default.invoke_url]
    issuer   = var.jwt_authorizer_issuer_url[terraform.workspace]
  }
}
