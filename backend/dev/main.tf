terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = "eu-west-2"
}

resource "aws_resourcegroups_group" "danflix-rg" {
  name = "danflix-${var.environment}"

  resource_query {
    query = <<JSON
{
"ResourceTypeFilters":
  [ "AWS::EC2::Instance" ],
"TagFilters":
  [
    {
      "Key": "Environment",
      "Values": ["${var.environment}"]
    }
  ]
}
  JSON
  }
}

# TODO: See aws_iam_policy_document for this.
resource "aws_iam_role" "danflix-iam-role-lambda" {
  name = "danflix-${var.environment}-iam-role-lambda"

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
    Environment = "${var.environment}"
  }
}

# TODO: See aws_iam_policy_document for this.
resource "aws_iam_policy" "danflix-iam-policy-storage-media" {
  name = "danflix-${var.environment}-iam-policy-storage-media"

  policy = <<EOF
{
"Version": "2012-10-17",
"Statement":
  [
    {
    "Sid": "ListObjectsInBucket",
    "Effect": "Allow",
    "Action": "s3:ListBucket",
    "Resource": [ "arn:aws:s3:::danflix-${var.environment}-storage-media" ]
    },
    {
    "Sid": "GetObjectInBucket",
    "Effect": "Allow",
    "Action": "s3:GetObject",
    "Resource": [ "arn:aws:s3:::danflix-${var.environment}-storage-media/*" ]
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
  bucket = "danflix-${var.environment}-storage-media"
  acl    = "private"

  tags = {
    Environment = "${var.environment}"
  }
}

resource "aws_s3_bucket" "danflix-storage-frontend" {
  bucket = "danflix-${var.environment}-storage-frontend"
  acl    = "private"

  tags = {
    Environment = "${var.environment}"
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
    origin_id   = "danflix-${var.environment}-storage-frontend"

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
    target_origin_id = "danflix-${var.environment}-storage-frontend"

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
    Environment = "${var.environment}"
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
  Bucket: 'danflix-onprem',
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
  function_name    = "danflix-${var.environment}-lambda-function-get-presignedurl"
  role             = aws_iam_role.danflix-iam-role-lambda.arn
  handler          = "index.handler"
  runtime          = "nodejs12.x"

  tags = {
    Environment = "${var.environment}"
  }
}

resource "aws_apigatewayv2_api" "danflix-api" {
  name          = "danflix-${var.environment}-api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["https://${aws_cloudfront_distribution.danflix-cloudfront-frontend.domain_name}"]
    allow_methods = ["GET"]
  }

  tags = {
    Environment = "${var.environment}"
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

resource "aws_apigatewayv2_stage" "danflix-api-stage-default" {
  api_id      = aws_apigatewayv2_api.danflix-api.id
  name        = "$default"
  auto_deploy = true

  tags = {
    Environment = "${var.environment}"
  }
}

resource "aws_apigatewayv2_authorizer" "danflix-api-authorizer" {
  api_id           = aws_apigatewayv2_api.danflix-api.id
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]
  name             = "danflix-${var.environment}-authorizer"

  jwt_configuration {
    audience = ["${aws_apigatewayv2_stage.danflix-api-stage-default.invoke_url}"]
    issuer   = var.authorizer_issuer_url
  }
}

output "api_invoke_url" {
  value = aws_apigatewayv2_stage.danflix-api-stage-default.invoke_url
}

output "cloudfront_distribution_domain" {
  value = aws_cloudfront_distribution.danflix-cloudfront-frontend.domain_name
}