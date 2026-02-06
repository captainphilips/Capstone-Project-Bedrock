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
  default     = "bedrock-assets-0347"
}

variable "tags" {
  description = "Tags to apply to serverless resources"
  type        = map(string)
  default     = {}
}
