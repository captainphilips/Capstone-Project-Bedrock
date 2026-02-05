############################
# Serverless Module Outputs
############################
output "lambda_name" {
  value = aws_lambda_function.this.function_name
}
