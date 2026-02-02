output "cluster_endpoint" {
  value = aws_eks_cluster.bedrock.endpoint
}

output "cluster_certificate_authority_data" {
  value = aws_eks_cluster.bedrock.certificate_authority[0].data
}

output "cluster_name" {
  value = aws_eks_cluster.bedrock.name
}

output "cluster_ca_certificate" {
  value = aws_eks_cluster.bedrock.certificate_authority[0].data
}

output "region" {
  value = "us-east-1"
}

output "vpc_id" {
  value = var.vpc_id
}

output "oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.bedrock.arn
}

output "oidc_provider_url" {
  value = aws_iam_openid_connect_provider.bedrock.url
}
