################################################################################
# EKS Cluster
################################################################################
locals {
  effective_subnet_ids = coalescelist(var.subnet_ids, var.private_subnet_ids)
}

resource "aws_eks_cluster" "bedrock" {
  name                      = var.cluster_name
  role_arn                  = aws_iam_role.eks_cluster.arn
  version                   = var.cluster_version
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  vpc_config {
    subnet_ids              = local.effective_subnet_ids
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
  subnet_ids      = local.effective_subnet_ids
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

################################################################################
# EKS Add-ons
################################################################################
resource "aws_eks_addon" "coredns" {
  cluster_name                = aws_eks_cluster.bedrock.name
  addon_name                  = "coredns"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name                = aws_eks_cluster.bedrock.name
  addon_name                  = "kube-proxy"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name                = aws_eks_cluster.bedrock.name
  addon_name                  = "vpc-cni"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
}

resource "aws_eks_addon" "ebs_csi" {
  cluster_name                = aws_eks_cluster.bedrock.name
  addon_name                  = "aws-ebs-csi-driver"
  service_account_role_arn    = aws_iam_role.ebs_csi_driver.arn
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
}
