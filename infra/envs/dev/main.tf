############################
# Dev Environment - Root Module
############################
# Orchestrates all modules for full stack deployment

############################
# Variables
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

variable "cluster_version" {
  description = "EKS Kubernetes version"
  type        = string
  default     = "1.29"
}

variable "use_existing_bedrock_dev_view_user" {
  description = "Set true if barakat-2025-capstone-bedrock-dev-view IAM user already exists"
  type        = bool
  default     = false
}

############################
# 1. VPC Module (no dependencies)
############################
module "vpc" {
  source = "../../modules/vpc"

  vpc_cidr    = local.vpc_cidr
  cluster_tag = local.cluster_name
  tags        = local.tags
}

############################
# 2. EKS Module (depends on VPC)
############################
module "eks" {
  source = "../../modules/eks"

  cluster_name       = local.cluster_name
  cluster_version    = var.cluster_version
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids  = module.vpc.private_subnets
  tags               = local.tags
}

############################
# 3. Persistence Module (depends on VPC)
############################
module "persistence" {
  source = "../../modules/persistence"

  environment        = local.environment
  vpc_id             = module.vpc.vpc_id
  vpc_cidr           = local.vpc_cidr
  private_subnet_ids  = module.vpc.private_subnets
  tags               = local.tags
}

############################
# 4. Observability Module (depends on EKS)
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
# 5. RBAC Module (depends on EKS)
############################
module "rbac" {
  source = "../../modules/rbac"

  cluster_name                       = module.eks.cluster_name
  oidc_provider                      = module.eks.oidc_provider
  assets_bucket_name                 = local.assets_bucket
  use_existing_bedrock_dev_view_user  = var.use_existing_bedrock_dev_view_user
  tags                               = local.tags
}

############################
# 6. Serverless Module (depends on VPC)
############################
module "serverless" {
  source = "../../modules/serverless"

  function_name      = local.lambda_name
  assets_bucket_name = local.assets_bucket
  lambda_zip_path    = abspath("${path.module}/../../../lambda/hello/build/handler.zip")
  vpc_id             = module.vpc.vpc_id
  tags               = local.tags
}

############################
# 7. App Module (depends on EKS, Persistence)
############################
module "app" {
  source = "../../modules/app"

  providers = {
    kubernetes = kubernetes
    helm       = helm
  }

  cluster_name        = module.eks.cluster_name
  namespace           = local.namespace
  catalog_db_endpoint  = module.persistence.mysql_endpoint
  catalog_db_port      = module.persistence.mysql_port
  catalog_db_username  = module.persistence.catalog_db_username
  catalog_db_password  = module.persistence.catalog_db_password
  orders_db_endpoint   = module.persistence.postgres_endpoint
  orders_db_port       = module.persistence.postgres_port
  orders_db_name       = module.persistence.orders_db_name
  orders_db_username   = module.persistence.orders_db_username
  orders_db_password   = module.persistence.orders_db_password
}

############################
# 8. External Secrets Module (depends on App)
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
# 9. ALB Controller Module (depends on App)
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
  namespace         = local.namespace

  depends_on = [module.app]
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
  description = "Access key ID for barakat-2025-capstone-bedrock-dev-view"
  value       = module.rbac.bedrock_dev_view_access_key_id
  sensitive   = true
}

output "bedrock_dev_view_secret_access_key" {
  description = "Secret access key for barakat-2025-capstone-bedrock-dev-view"
  value       = module.rbac.bedrock_dev_view_secret_access_key
  sensitive   = true
}
