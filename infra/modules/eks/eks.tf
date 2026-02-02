################################################################################
# EKS Cluster
################################################################################

resource "aws_eks_cluster" "bedrock" {
  name               = var.cluster_name
  role_arn           = aws_iam_role.eks_cluster.arn
  version            = var.cluster_version
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  vpc_config {
    subnet_ids              = var.private_subnet_ids
    endpoint_public_access  = true
    endpoint_private_access = true
  }

  tags = merge(
    var.tags,
    {
      Project = "Bedrock"
    }
  )

  depends_on = [aws_iam_role_policy_attachment.eks_cluster]
}

# Auth data source (provides a token for kubectl)
data "aws_eks_cluster_auth" "bedrock" {
  name = aws_eks_cluster.bedrock.name
}

################################################################################
# Managed Node Group (t3.medium × 2 nodes — cost-conscious)
################################################################################

resource "aws_eks_node_group" "bedrock" {
  cluster_name    = aws_eks_cluster.bedrock.name
  node_group_name = "project-bedrock-nodes"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = var.private_subnet_ids
  instance_types  = ["t3.medium"]

  scaling_config {
    desired_size = 2
    min_size     = 2
    max_size     = 3
  }

  tags = merge(
    var.tags,
    {
      Project = "Bedrock"
    }
  )

  depends_on = [aws_iam_role_policy_attachment.eks_nodes]
}
