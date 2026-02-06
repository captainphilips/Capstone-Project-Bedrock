############################
# Serverless Module Outputs
############################
output "lambda_name" {
  value = aws_lambda_function.this.function_name
}

output "assets_bucket_name" {
  value = aws_s3_bucket.assets.bucket
}
