############################
# Serverless Module Outputs
############################
output "assets_bucket_name" {
  description = "S3 bucket for assets"
  value       = aws_s3_bucket.bedrock_assets.bucket
}

output "lambda_function_arn" {
  description = "Lambda function ARN"
  value       = aws_lambda_function.asset_processor.arn
}
