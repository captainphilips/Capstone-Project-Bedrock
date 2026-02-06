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
  region       = var.aws_region
  environment  = var.environment
  cluster_name = "project-bedrock-cluster"

  tags = {
    Project     = "barakat-2025-capstone"
    Environment = local.environment
    ManagedBy   = "Terraform"
  }
}

############################
# VPC Module
############################
module "vpc" {
  source = "../../modules/vpc"

  vpc_cidr = "10.0.0.0/16"
  tags     = local.tags
}

############################
# EKS Module
############################
module "eks" {
  source = "../../modules/eks"

  cluster_name    = local.cluster_name
  cluster_version = "1.34"
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets
  tags            = local.tags
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
# RBAC Module
############################
module "rbac" {
  source = "../../modules/rbac"

  cluster_name       = module.eks.cluster_name
  oidc_provider      = module.eks.oidc_provider
  assets_bucket_name = "bedrock-assets-0347"
  tags               = local.tags
}

############################
# Serverless Module
############################
module "serverless" {
  source = "../../modules/serverless"

  function_name      = "bedrock-asset-processor"
  assets_bucket_name = "bedrock-assets-0347"
  tags               = local.tags
}

############################
# App Module
############################
module "app" {
  source = "../../modules/app"

  cluster_name = module.eks.cluster_name
  namespace    = "retail-app"
}

############################
# Outputs
############################
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "region" {
  description = "AWS region"
  value       = local.region
}

output "assets_bucket_name" {
  description = "Assets bucket name"
  value       = module.serverless.assets_bucket_name
}

output "bedrock_dev_view_access_key_id" {
  description = "Access key ID for bedrock-dev-view"
  value       = module.rbac.bedrock_dev_view_access_key_id
  sensitive   = true
}

output "bedrock_dev_view_secret_access_key" {
  description = "Secret access key for bedrock-dev-view"
  value       = module.rbac.bedrock_dev_view_secret_access_key
  sensitive   = true
}
