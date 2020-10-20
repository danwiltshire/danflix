resource "aws_lambda_function" "this" {
  function_name    = "${var.resource_prefix}-function-getsignedcookie"
  handler          = "index.handler"
  runtime          = "nodejs12.x"
}
