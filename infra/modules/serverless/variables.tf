############################
# Serverless Module Variables
############################
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

variable "function_name" {
  description = "Lambda function name (compat alias)"
  type        = string
  default     = null
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
