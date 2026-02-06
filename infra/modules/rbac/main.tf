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
      Project = "Bedrock"
    }
  )
}

resource "aws_iam_user" "bedrock_dev_view" {
  name = "bedrock-dev-view"

  tags = merge(
    var.tags,
    {
      Project = "Bedrock"
    }
  )
}
