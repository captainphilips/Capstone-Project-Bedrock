############################
# Dev Environment - Root Module
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
  assets_bucket_name   = "bedrock-assets-dev-0347"
  lambda_function_name = "bedrock-asset-processor-dev"
  azs                  = ["us-east-1a", "us-east-1b"]

  tags = {
    Project     = "Bedrock"
    Environment = local.environment
    ManagedBy   = "Terraform"
  }
}

############################
# VPC Module
############################
module "vpc" {
  source = "../../modules/vpc"

  azs  = local.azs
  tags = local.tags
}

############################
# EKS Module
############################
module "eks" {
  source = "../../modules/eks"

  cluster_name       = local.cluster_name
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  tags               = local.tags
}

############################
# Observability Module
############################
module "observability" {
  source = "../../modules/observability"

  cluster_name       = module.eks.cluster_name
  log_retention_days = 7
  oidc_provider_url  = module.eks.oidc_provider_url
  oidc_provider_arn  = module.eks.oidc_provider_arn
  tags               = local.tags
}

############################
# Serverless Module
############################
module "serverless" {
  source = "../../modules/serverless"

  assets_bucket_name   = local.assets_bucket_name
  lambda_function_name = local.lambda_function_name
  lambda_runtime       = "python3.11"
  tags                 = local.tags
}

############################
# Outputs
############################
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "nat_gateway_ips" {
  description = "NAT Gateway IPs"
  value       = module.vpc.nat_gateway_ips
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "assets_bucket_name" {
  description = "S3 assets bucket name"
  value       = module.serverless.assets_bucket_name
}
