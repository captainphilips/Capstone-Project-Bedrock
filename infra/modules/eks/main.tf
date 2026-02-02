############################
# EKS Cluster Module
############################
# This module manages the EKS cluster, node groups, and IAM roles.
#
# To be implemented with:
# - aws_eks_cluster resource
# - aws_eks_node_group resources
# - OIDC provider for IRSA
# - Security groups for cluster and nodes
#
# IAM roles are defined in iam.tf
# Input variables are defined in variables.tf
# Outputs are defined in outputs.tf

############################
# Control Plane Logs
############################
# Enable CloudWatch logging for EKS control plane
resource "aws_cloudwatch_log_group" "eks_cluster" {
  name              = "/aws/eks/project-bedrock-cluster/cluster"
  retention_in_days = 7

  tags = {
    Project = "Bedrock"
  }
}

############################
# EKS Cluster Resource
############################
# TODO: Implement aws_eks_cluster resource with:
#   - enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
#   - cloudwatch_log_group_name = aws_cloudwatch_log_group.eks_cluster.name

# TODO: Implement EKS node groups
# TODO: Implement OIDC provider for IRSA
# TODO: Implement security groups

