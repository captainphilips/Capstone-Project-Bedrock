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

  backend "s3" {
    bucket         = "project-bedrock-0347-tf-state"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "project-bedrock-tf-lock"
    encrypt        = true
  }
}

############################
# Providers
############################
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.tags
  }
}

# Kubernetes provider will be configured after EKS cluster is created
# provider "kubernetes" {
#   host                   = module.eks.cluster_endpoint
#   cluster_ca_certificate = base64decode(module.eks.cluster_ca_certificate)
#   token                  = data.aws_eks_cluster_auth.cluster.token
# }

# data "aws_eks_cluster_auth" "cluster" {
#   name = module.eks.cluster_name
# }

# provider "helm" {
#   kubernetes {
#     host                   = module.eks.cluster_endpoint
#     cluster_ca_certificate = base64decode(module.eks.cluster_ca_certificate)
#     token                  = data.aws_eks_cluster_auth.cluster.token
#   }
# }
