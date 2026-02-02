############################
# Parameters / Locals
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

/* Lambda function resource intentionally omitted.
   Add a deployment package (lambda.zip) or reference an S3 artifact
   and reintroduce the Lambda resource in a module when ready. */
