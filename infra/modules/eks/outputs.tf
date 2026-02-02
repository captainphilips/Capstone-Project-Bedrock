############################
# EKS Module Outputs
############################
output "cluster_name" {
  description = "EKS cluster name"
  value       = ""
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

output "eks_cluster_role_arn" {
  description = "ARN of the EKS cluster IAM role"
  value       = aws_iam_role.eks_cluster.arn
}

output "eks_nodes_role_arn" {
  description = "ARN of the EKS node group IAM role"
  value       = aws_iam_role.eks_nodes.arn
}
