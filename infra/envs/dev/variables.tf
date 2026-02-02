############################
# Dev Environment - Variables
############################

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

locals {
  region               = var.aws_region
  environment          = var.environment
  cluster_name         = "project-bedrock-dev-cluster"
  vpc_name_tag         = "project-bedrock-dev-vpc"
  app_namespace        = "retail-app"
  developer_iam_user   = "bedrock-dev-view"
  assets_bucket_name   = "bedrock-assets-dev-0347"
  lambda_function_name = "bedrock-asset-processor-dev"
  azs                  = ["us-east-1a", "us-east-1b"]

  tags = {
    Project     = "Bedrock"
    Environment = local.environment
    ManagedBy   = "Terraform"
  }
}
