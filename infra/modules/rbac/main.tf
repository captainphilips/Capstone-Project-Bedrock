############################
# RBAC Module - IAM Roles for Service Accounts (IRSA)
############################
resource "aws_iam_role" "eks_irsa_role" {
  name = "eks-irsa-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = var.oidc_provider }
      Action    = "sts:AssumeRoleWithWebIdentity"
    }]
  })

  tags = merge(
    var.tags,
    {
      Project = "barakat-2025-capstone"
    }
  )
}

resource "aws_iam_user" "bedrock_dev_view" {
  name = "bedrock-dev-view"

  tags = merge(
    var.tags,
    {
      Project = "barakat-2025-capstone"
    }
  )
}

resource "aws_iam_user_policy_attachment" "bedrock_dev_view_ro" {
  user       = aws_iam_user.bedrock_dev_view.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_user_policy" "bedrock_dev_view_eks_describe" {
  name = "bedrock-dev-view-eks-describe"
  user = aws_iam_user.bedrock_dev_view.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["eks:DescribeCluster"]
        Resource = "arn:aws:eks:*:*:cluster/project-bedrock-cluster"
      }
    ]
  })
}

resource "aws_iam_user_policy" "bedrock_dev_view_bucket_put" {
  name = "bedrock-dev-view-bucket-put"
  user = aws_iam_user.bedrock_dev_view.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl"
        ]
        Resource = "arn:aws:s3:::${var.assets_bucket_name}/*"
      }
    ]
  })
}

resource "aws_iam_access_key" "bedrock_dev_view" {
  user = aws_iam_user.bedrock_dev_view.name
}

resource "aws_eks_access_entry" "bedrock_dev_view" {
  cluster_name  = var.cluster_name
  principal_arn = aws_iam_user.bedrock_dev_view.arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "bedrock_dev_view" {
  cluster_name  = var.cluster_name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
  principal_arn = aws_iam_user.bedrock_dev_view.arn

  access_scope {
    type = "cluster"
  }
}
