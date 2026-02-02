############################
# EKS Cluster Module
############################
# This module manages the EKS cluster, node groups, and IAM roles.
# To be implemented with:
# - aws_eks_cluster
# - aws_eks_node_group
# - aws_iam_role for cluster and node roles
# - OIDC provider for IRSA
# - Security groups

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.27"
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for worker nodes"
  type        = list(string)
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

# Placeholder: implement EKS cluster, node groups, and IAM roles
output "cluster_name" {
  description = "EKS cluster name"
  value       = var.cluster_name
}

output "cluster_endpoint" {
  description = "EKS cluster API endpoint"
  value       = ""
}

output "cluster_ca_certificate" {
  description = "Base64 encoded cluster CA certificate"
  value       = ""
}

output "oidc_provider_arn" {
  description = "ARN of OIDC provider for IRSA"
  value       = ""
}
