

############################
# Parameters / locals
############################
locals {
  region               = "us-east-1"
  cluster_name         = "project-bedrock-cluster"
  vpc_name_tag         = "project-bedrock-vpc"
  app_namespace        = "retail-app"
  developer_iam_user   = "bedrock-dev-view"
  assets_bucket_name   = "bedrock-assets-0347"
  lambda_function_name = "bedrock-asset-processor"
  azs                  = ["us-east-1a", "us-east-1b"]

  # Mandatory tagging policy
  tags = {
    Project = "Bedrock"
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
# AWS Resources
############################

# S3 bucket for assets
resource "aws_s3_bucket" "assets" {
  bucket = local.assets_bucket_name
}

# IAM user (developer)
resource "aws_iam_user" "developer" {
  name = local.developer_iam_user
}

# Lambda execution role (for Lambda function when added)
resource "aws_iam_role" "lambda_exec" {
  name = "${local.lambda_function_name}-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = { Service = "lambda.amazonaws.com" }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

############################
# Variables
############################
variable "cluster_endpoint" {
  description = "EKS cluster endpoint (set once EKS is created)."
  type        = string
  default     = ""
}

############################
# Terraform Outputs
############################
output "cluster_endpoint" {
  description = "EKS cluster API server endpoint"
  value       = var.cluster_endpoint
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = local.cluster_name
}

output "region" {
  description = "AWS region"
  value       = local.region
}

output "vpc_id" {
  description = "VPC ID from VPC module"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs from VPC module"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs from VPC module"
  value       = module.vpc.private_subnet_ids
}

output "nat_gateway_ips" {
  description = "NAT Gateway public IPs from VPC module"
  value       = module.vpc.nat_gateway_ips
}

output "assets_bucket_name" {
  description = "S3 bucket name for assets"
  value       = aws_s3_bucket.assets.bucket
}



