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
# Terraform Module: VPC
############################
module "vpc" {
  source = "./terraform"

  azs = local.azs

  tags = local.tags
}
