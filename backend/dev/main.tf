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
data "archive_file" "danflix-lambda-code-getPresignedURL" {
  type        = "zip"
  output_path = "/tmp/danflix-lambda-code-getPresignedURL.zip"
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

resource "aws_lambda_function" "danflix-lambda-function-getPresignedURL" {
  filename         = data.archive_file.danflix-lambda-code-getPresignedURL.output_path
  source_code_hash = data.archive_file.danflix-lambda-code-getPresignedURL.output_base64sha256
  function_name    = "danflix-${var.environment}-lambda-function-getPresignedURL"
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
}

resource "aws_apigatewayv2_route" "danflix-api-route-getPresignedURL" {
  api_id    = aws_apigatewayv2_api.danflix-api.id
  route_key = "GET /getpresignedurl"
  target    = "integrations/${aws_apigatewayv2_integration.danflix-api-route-getPresignedURL-integration.id}"
}

resource "aws_apigatewayv2_integration" "danflix-api-route-getPresignedURL-integration" {
  api_id             = aws_apigatewayv2_api.danflix-api.id
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
  integration_uri    = aws_lambda_function.danflix-lambda-function-getPresignedURL.invoke_arn
}

resource "aws_apigatewayv2_stage" "danflix-api-stage-default" {
  api_id      = aws_apigatewayv2_api.danflix-api.id
  name        = "danflix-${var.environment}-default"
  auto_deploy = true
}