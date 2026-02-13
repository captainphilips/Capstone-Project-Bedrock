############################
# Serverless Module Variables
############################
variable "function_name" {
  description = "Lambda function name"
  type        = string
}

variable "assets_bucket_name" {
  description = "S3 bucket for assets"
  type        = string
}

variable "lambda_zip_path" {
  description = "Path to Lambda deployment package (zip file)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for tagging and association (barakat-2025-capstone-bedrock-vpc)"
  type        = string
  default     = null
}

variable "lambda_log_retention_days" {
  description = "CloudWatch log retention for Lambda (days)"
  type        = number
  default     = 14
}

variable "tags" {
  description = "Tags to apply to serverless resources"
  type        = map(string)
  default     = {}
}
