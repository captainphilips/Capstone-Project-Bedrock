############################
# Capstone Project - Root Module
############################

############################
# Terraform Configuration
############################
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12"
    }
  }

  # Backend configuration - Uncomment to use S3 backend
  # backend "s3" {
  #   bucket         = "project-bedrock-0347-tf-state"
  #   key            = "root/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "project-bedrock-tf-lock"
  #   encrypt        = true
  # }
}

############################
# Providers
############################
provider "aws" {
  region = local.region

  default_tags {
    tags = local.tags
  }
}

# Kubernetes provider uses EKS module outputs
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_ca_certificate)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_ca_certificate)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    }
  }
}

############################
# Locals
############################
locals {
  region               = "us-east-1"
  environment          = "dev"
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

############################
# VPC Module
############################
module "vpc" {
  source = "./infra/modules/vpc"

  azs  = local.azs
  tags = local.tags
}

############################
# EKS Module
############################
module "eks" {
  source = "./infra/modules/eks"

  cluster_name       = local.cluster_name
  cluster_version    = "1.27"
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  tags               = local.tags
}

############################
# IAM Module
############################
module "iam" {
  source = "./infra/modules/iam"

  developer_username = local.developer_iam_user
  cluster_name       = local.cluster_name
  tags               = local.tags
}

############################
# RBAC Module
############################
module "rbac" {
  source = "./infra/modules/rbac"

  cluster_name       = module.eks.cluster_name
  developer_username = module.iam.developer_username
  tags               = local.tags

  depends_on = [module.eks]
}

############################
# Observability Module
############################
module "observability" {
  source = "./infra/modules/observability"

  cluster_name       = module.eks.cluster_name
  log_retention_days = 7
  oidc_provider_url  = module.eks.oidc_provider_url
  oidc_provider_arn  = module.eks.oidc_provider_arn
  tags               = local.tags

  depends_on = [module.eks]
}

############################
# App Module
############################
module "app" {
  source = "./infra/modules/app"

  cluster_name           = module.eks.cluster_name
  cluster_endpoint       = module.eks.cluster_endpoint
  cluster_ca_certificate = module.eks.cluster_ca_certificate
  app_namespace          = local.app_namespace
  tags                   = local.tags

  depends_on = [module.eks]
}

############################
# Serverless Module
############################
module "serverless" {
  source = "./infra/modules/serverless"

  assets_bucket_name   = local.assets_bucket_name
  lambda_function_name = local.lambda_function_name
  lambda_runtime       = "python3.11"
  tags                 = local.tags
}
