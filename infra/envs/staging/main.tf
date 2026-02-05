############################
# Staging Environment - Root Module
############################
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "staging"
}

locals {
  region       = var.aws_region
  environment  = var.environment
  cluster_name = "project-bedrock-staging-cluster"
  azs          = ["us-east-1a", "us-east-1b"]

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

  function_name = "bedrock-hello"
}

############################
# Outputs
############################
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnets
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
  description = "Lambda function name"
  value       = module.serverless.lambda_name
}
