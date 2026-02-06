################################################################################
# IAM Role for the CloudWatch agent (IRSA — IAM Roles for Service Accounts)
################################################################################

resource "aws_iam_role" "cloudwatch_agent" {
  name = "project-bedrock-cw-agent-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = var.oidc_provider_arn
        }
        Condition = {
          StringEquals = {
            "${replace(var.oidc_provider_url, "https://", "")}:sub" = "system:serviceaccount:amazon-cloudwatch:amazon-cloudwatch"
          }
        }
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Project = "barakat-2025-capstone"
    }
  )
}

resource "aws_iam_role_policy_attachment" "cw_agent" {
  role       = aws_iam_role.cloudwatch_agent.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

################################################################################
# EKS Add-on: Amazon CloudWatch Observability
################################################################################

resource "aws_eks_addon" "cloudwatch" {
  cluster_name  = var.cluster_name
  addon_name    = "amazon-cloudwatch-observability"
  addon_version = "v1.3.0-eksbuild.1"
  # Check latest: aws eks describe-addon-versions --addon-name amazon-cloudwatch-observability
  service_account_role_arn    = aws_iam_role.cloudwatch_agent.arn
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  tags = merge(
    var.tags,
    {
      Project = "barakat-2025-capstone"
    }
  )
}
