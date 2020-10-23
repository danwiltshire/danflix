output "function_name" {
  value = var.function_name
}

output "invoke_arn" {
  value = aws_lambda_function.this.invoke_arn
}
