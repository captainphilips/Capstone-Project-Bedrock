output "bedrock_dev_view_access_key_id" {
  description = "Access key ID for barakat-2025-capstone-bedrock-dev-view"
  value       = aws_iam_access_key.bedrock_dev_view.id
  sensitive   = true
}

output "bedrock_dev_view_secret_access_key" {
  description = "Secret access key for barakat-2025-capstone-bedrock-dev-view"
  value       = aws_iam_access_key.bedrock_dev_view.secret
  sensitive   = true
}

output "bedrock_dev_view_arn" {
  description = "IAM user ARN for barakat-2025-capstone-bedrock-dev-view"
  value       = local.bedrock_dev_view_user_arn
}
