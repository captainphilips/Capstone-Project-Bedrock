############################
# Prod Environment - Locals
############################
locals {
  cluster_name  = "barakat-2025-capstone-bedrock-cluster"
  region        = var.aws_region
  environment   = var.environment
  vpc_name      = "barakat-2025-capstone-bedrock-vpc"
  vpc_cidr      = "10.0.0.0/16"
  assets_bucket = "barakat-2025-capstone-bedrock-assets-0347"
  lambda_name   = "barakat-2025-capstone-bedrock-asset-processor"
  namespace     = "retail-app"

  tags = {
    Project     = "barakat-2025-capstone-bedrock"
    Environment = "prod"
    ManagedBy   = "Terraform"
  }
}
