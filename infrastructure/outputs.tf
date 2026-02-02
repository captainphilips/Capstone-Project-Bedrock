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
