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
