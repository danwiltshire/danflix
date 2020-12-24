data "archive_file" "this" {
  type        = "zip"
  output_path = "/tmp/${var.function_name}.zip"
  source {
    content  = var.lambda_template
    filename = "index.js"
  }
}

resource "aws_lambda_function" "this" {
  function_name    = var.function_name
  handler          = var.handler
  runtime          = var.runtime
  filename         = data.archive_file.this.output_path
  source_code_hash = data.archive_file.this.output_base64sha256
  role = var.role_arn
  environment {
    variables = var.lambda_env_vars
  }
}
