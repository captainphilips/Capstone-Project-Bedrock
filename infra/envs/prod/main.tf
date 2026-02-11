############################
# Prod Environment - Root Module
############################
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

locals {
  region        = var.aws_region
  environment   = var.environment
  cluster_name  = "project-bedrock-cluster"
  vpc_name      = "project-bedrock-vpc"
  assets_bucket = "bedrock-assets-ALTSOE025-0347"
  lambda_name   = "bedrock-asset-processor"
  namespace     = "retail-app"

  tags = {
    Project     = "Bedrock-Terraform"
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
# Persistence Module
############################
module "persistence" {
  source = "../../modules/persistence"

  environment        = local.environment
  vpc_id             = module.vpc.vpc_id
  vpc_cidr           = "10.0.0.0/16"
  private_subnet_ids = module.vpc.private_subnets
  multi_az           = true
  tags               = local.tags
}

############################
# RBAC Module
############################
module "rbac" {
  source = "../../modules/rbac"

  cluster_name       = module.eks.cluster_name
  oidc_provider      = module.eks.oidc_provider
  assets_bucket_name = local.assets_bucket
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
# Serverless Module (Lambda bedrock-asset-processor + S3 bucket, synced with VPC)
############################
module "serverless" {
  source = "../../modules/serverless"

  function_name      = local.lambda_name
  assets_bucket_name = local.assets_bucket
  lambda_zip_path    = "${path.root}/../../../lambda/hello/build/handler.zip"
  vpc_id             = module.vpc.vpc_id
  tags               = local.tags
}

############################
# External Secrets Module (depends on app for retail-app namespace)
############################
module "external_secrets" {
  source = "../../modules/external_secrets"

  providers = {
    kubernetes = kubernetes
    helm       = helm
  }

  cluster_name        = module.eks.cluster_name
  oidc_provider_arn   = module.eks.oidc_provider_arn
  oidc_provider_url   = module.eks.oidc_provider_url
  region              = local.region
  namespace           = local.namespace
  mysql_secret_arn    = module.persistence.mysql_secret_arn
  postgres_secret_arn = module.persistence.postgres_secret_arn

  depends_on = [module.app]
}

############################
# ALB Controller Module (depends on app for retail-app namespace & retail-store-ui service)
############################
module "alb_controller" {
  source = "../../modules/alb_controller"

  providers = {
    kubernetes = kubernetes
    helm       = helm
  }

  cluster_name      = module.eks.cluster_name
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url
  vpc_id            = module.vpc.vpc_id
  region            = local.region
  namespace         = "retail-app"

  depends_on = [module.app]
}

############################
# App Module (creates retail-app namespace via Helm)
############################
module "app" {
  source = "../../modules/app"

  providers = {
    kubernetes = kubernetes
    helm       = helm
  }

  cluster_name        = module.eks.cluster_name
  namespace           = local.namespace
  catalog_db_endpoint = module.persistence.mysql_endpoint
  catalog_db_port     = module.persistence.mysql_port
  catalog_db_username = module.persistence.catalog_db_username
  catalog_db_password = module.persistence.catalog_db_password
  orders_db_endpoint  = module.persistence.postgres_endpoint
  orders_db_port      = module.persistence.postgres_port
  orders_db_name      = module.persistence.orders_db_name
  orders_db_username  = module.persistence.orders_db_username
  orders_db_password  = module.persistence.orders_db_password
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
