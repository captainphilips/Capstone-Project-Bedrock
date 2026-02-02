############################
# Terraform Version & Providers
############################
terraform {
  backend "s3" {
    bucket         = "project-bedrock-0347-tf-state"
    key            = "project-bedrock/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "project-bedrock-tf-lock"
    encrypt        = true
  }

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
}

############################
# AWS Provider
############################
provider "aws" {
  region = local.region

  default_tags {
    tags = local.tags
  }
}

############################
# Terraform Module: VPC
############################
module "vpc" {
  source = "./modules/vpc"

  azs = local.azs

  tags = local.tags
}
