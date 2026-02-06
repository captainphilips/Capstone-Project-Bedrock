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

  vpc_cidr = "10.0.0.0/16"
  tags     = local.tags
}

############################
# EKS Module
############################
module "eks" {
  source = "../../modules/eks"

  cluster_name = local.cluster_name
  vpc_id       = module.vpc.vpc_id
  subnet_ids   = module.vpc.private_subnets
  tags         = local.tags
}

############################
# RBAC Module
############################
module "rbac" {
  source = "../../modules/rbac"

  cluster_name  = module.eks.cluster_name
  oidc_provider = module.eks.oidc_provider
  tags          = local.tags
}

############################
# Serverless Module
############################
module "serverless" {
  source = "../../modules/serverless"

  function_name      = "bedrock-asset-processor"
  assets_bucket_name = "bedrock-asset-ALT/SOE/025/0347"
  tags               = local.tags
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
