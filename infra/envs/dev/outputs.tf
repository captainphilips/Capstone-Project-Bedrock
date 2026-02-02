############################
# Dev Environment - Outputs
############################

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "nat_gateway_ips" {
  description = "NAT Gateway IPs"
  value       = module.vpc.nat_gateway_ips
}

# output "cluster_endpoint" {
#   description = "EKS cluster endpoint"
#   value       = module.eks.cluster_endpoint
# }
#
# output "cluster_name" {
#   description = "EKS cluster name"
#   value       = module.eks.cluster_name
# }
#
# output "assets_bucket_name" {
#   description = "S3 assets bucket name"
#   value       = module.serverless.assets_bucket_name
# }
