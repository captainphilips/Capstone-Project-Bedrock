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
      Project = "Bedrock-Terraform"
    }
  )
}

data "aws_iam_user" "bedrock_dev_view" {
  count     = var.use_existing_bedrock_dev_view_user ? 1 : 0
  user_name = "bedrock-dev-view"
}

resource "aws_iam_user" "bedrock_dev_view" {
  count = var.use_existing_bedrock_dev_view_user ? 0 : 1
  name  = "bedrock-dev-view"

  tags = merge(
    var.tags,
    {
      Project = "Bedrock-Terraform"
    }
  )
}

locals {
  bedrock_dev_view_user_name = var.use_existing_bedrock_dev_view_user ? data.aws_iam_user.bedrock_dev_view[0].user_name : aws_iam_user.bedrock_dev_view[0].name
  bedrock_dev_view_user_arn  = var.use_existing_bedrock_dev_view_user ? data.aws_iam_user.bedrock_dev_view[0].arn : aws_iam_user.bedrock_dev_view[0].arn
}

resource "aws_iam_user_policy_attachment" "bedrock_dev_view_ro" {
  user       = local.bedrock_dev_view_user_name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_user_policy" "bedrock_dev_view_eks_describe" {
  name = "bedrock-dev-view-eks-describe"
  user = local.bedrock_dev_view_user_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["eks:DescribeCluster"]
        Resource = "arn:aws:eks:*:*:cluster/${var.cluster_name}"
      }
    ]
  })
}

resource "aws_iam_user_policy" "bedrock_dev_view_bucket_put" {
  name = "bedrock-dev-view-bucket-put"
  user = local.bedrock_dev_view_user_name

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
  user = local.bedrock_dev_view_user_name
}

resource "aws_eks_access_entry" "bedrock_dev_view" {
  cluster_name  = var.cluster_name
  principal_arn = local.bedrock_dev_view_user_arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "bedrock_dev_view" {
  cluster_name  = var.cluster_name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
  principal_arn = local.bedrock_dev_view_user_arn

  access_scope {
    type = "cluster"
  }
}
