resource "aws_iam_user" "bedrock_dev" {
  name = "bedrock-dev-view"
  tags = {
    Project = "Bedrock"
  }
}

# Attach AWS managed ReadOnlyAccess policy
resource "aws_iam_user_policy_attachment" "bedrock_dev_readonly" {
  user       = aws_iam_user.bedrock_dev.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

# Generate a login profile for this user
resource "aws_iam_user_login_profile" "bedrock_dev" {
  user = aws_iam_user.bedrock_dev.name
}

# Generate an access key for this user
resource "aws_iam_access_key" "bedrock_dev" {
  user = aws_iam_user.bedrock_dev.name
}

# Output the credentials (sensitive — for grading submission only)
output "dev_access_key_id" {
  value     = aws_iam_access_key.bedrock_dev.id
  sensitive = true
}

output "dev_secret_access_key" {
  value     = aws_iam_access_key.bedrock_dev.secret
  sensitive = true
}

# Retrieve sensitive outputs:
# terraform output -json | jq '.dev_access_key_id.value, .dev_secret_access_key.value'

# We need the IAM user's ARN to add to aws-auth.
# The aws-auth ConfigMap maps IAM identities to K8s RBAC subjects.
data "aws_iam_user" "bedrock_dev" {
  user_name = aws_iam_user.bedrock_dev.name
  depends_on = [aws_iam_user.bedrock_dev]
}

# Patch the aws-auth ConfigMap to add our dev user
resource "kubernetes_config_map_v1_data" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  # EKS creates aws-auth automatically. We force_conflicts to take ownership.
  force_conflicts = true

  data = {
    mapUsers = yamlencode([
      {
        userarn  = data.aws_iam_user.bedrock_dev.arn
        username = "bedrock-dev-view"
        groups   = ["dev-viewers"]
        # ← custom group, NOT system:masters
      }
    ])
  }

  depends_on = [aws_eks_cluster.bedrock]
}
