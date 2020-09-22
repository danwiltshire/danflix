terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
    auth0 = {
      source  = "alexkappa/auth0"
      version = "> 0.8"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = "eu-west-2"
}

provider "auth0" {
  domain        = env.auth0_domain
  client_id     = env.auth0_client_id
  client_secret = env.auth0_client_secret
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