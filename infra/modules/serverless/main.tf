############################
# Serverless Module - S3, Lambda, & Triggers
############################
# Manages serverless components: S3 bucket for assets, Lambda processor

variable "assets_bucket_name" {
  description = "S3 bucket name for assets"
  type        = string
  default     = "bedrock-assets-0347"
}

variable "lambda_function_name" {
  description = "Lambda function name"
  type        = string
  default     = "bedrock-asset-processor"
}

variable "lambda_runtime" {
  description = "Lambda runtime"
  type        = string
  default     = "python3.11"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

# Placeholder: implement S3 bucket and Lambda function
output "assets_bucket_name" {
  description = "S3 bucket for assets"
  value       = var.assets_bucket_name
}

output "lambda_function_arn" {
  description = "Lambda function ARN"
  value       = ""
}
