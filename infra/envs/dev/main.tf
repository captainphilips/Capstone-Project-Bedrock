############################
# Dev Environment - Root Module
############################
# This file orchestrates all modules for the dev environment

############################
# VPC Module
############################
module "vpc" {
  source = "../../modules/vpc"

  azs  = local.azs
  tags = local.tags
}

############################
# EKS Module (placeholder)
############################
# module "eks" {
#   source = "../../modules/eks"
#
#   cluster_name       = local.cluster_name
#   cluster_version    = "1.27"
#   vpc_id             = module.vpc.vpc_id
#   private_subnet_ids = module.vpc.private_subnet_ids
#   tags               = local.tags
# }

############################
# IAM Module
############################
# module "iam" {
#   source = "../../modules/iam"
#
#   developer_username = local.developer_iam_user
#   cluster_name       = local.cluster_name
#   tags               = local.tags
# }

############################
# RBAC Module
############################
# module "rbac" {
#   source = "../../modules/rbac"
#
#   cluster_name       = module.eks.cluster_name
#   developer_username = module.iam.developer_username
#   tags               = local.tags
# }

############################
# Observability Module
############################
# module "observability" {
#   source = "../../modules/observability"
#
#   cluster_name      = module.eks.cluster_name
#   log_retention_days = 7
#   tags              = local.tags
# }

############################
# App Module
############################
# module "app" {
#   source = "../../modules/app"
#
#   cluster_name           = module.eks.cluster_name
#   cluster_endpoint       = module.eks.cluster_endpoint
#   cluster_ca_certificate = module.eks.cluster_ca_certificate
#   app_namespace          = local.app_namespace
#   tags                   = local.tags
# }

############################
# Serverless Module
############################
# module "serverless" {
#   source = "../../modules/serverless"
#
#   assets_bucket_name     = local.assets_bucket_name
#   lambda_function_name   = local.lambda_function_name
#   lambda_runtime         = "python3.11"
#   tags                   = local.tags
# }
