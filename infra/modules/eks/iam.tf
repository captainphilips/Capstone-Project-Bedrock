############################
# EKS Cluster IAM Role
############################
# IAM Role for EKS control plane (least privilege — only what EKS control plane needs)

resource "aws_iam_role" "eks_cluster" {
  name = "project-bedrock-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Project = "Bedrock"
  }
}

resource "aws_iam_role_policy_attachment" "eks_cluster" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  ])

  role       = aws_iam_role.eks_cluster.name
  policy_arn = each.value
}

############################
# EKS Node Group IAM Role
############################
# IAM Role for worker nodes with permissions for container registry access, CNI plugin, and node operations

resource "aws_iam_role" "eks_nodes" {
  name = "project-bedrock-eks-nodes-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Project = "Bedrock"
  }
}

resource "aws_iam_role_policy_attachment" "eks_nodes" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  ])

  role       = aws_iam_role.eks_nodes.name
  policy_arn = each.value
}
