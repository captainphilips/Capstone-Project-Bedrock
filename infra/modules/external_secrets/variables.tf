variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "oidc_provider_arn" {
  description = "OIDC provider ARN for IRSA"
  type        = string
}

variable "oidc_provider_url" {
  description = "OIDC provider URL for IRSA"
  type        = string
}

variable "mysql_secret_arn" {
  description = "Secrets Manager ARN for catalog DB"
  type        = string
}

variable "postgres_secret_arn" {
  description = "Secrets Manager ARN for orders DB"
  type        = string
}

variable "namespace" {
  description = "Namespace for retail app secrets"
  type        = string
  default     = "retail-app"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "tags" {
  description = "Tags to apply to IAM resources"
  type        = map(string)
  default     = {}
}
