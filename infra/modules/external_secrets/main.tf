terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0"
    }
  }
}

data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "this" {
  name = var.cluster_name
}

locals {
  namespace       = "external-secrets"
  service_account = "external-secrets"
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes = {
    host                   = data.aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(var.oidc_provider_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:${local.namespace}:${local.service_account}"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(var.oidc_provider_url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "external_secrets" {
  name               = "project-bedrock-external-secrets-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  tags = merge(
    var.tags,
    {
      Project = "barakat-2025-capstone"
    }
  )
}

data "aws_iam_policy_document" "secrets_access" {
  statement {
    effect  = "Allow"
    actions = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
    resources = var.secret_arns
  }
}

resource "aws_iam_policy" "secrets_access" {
  name   = "project-bedrock-secrets-access"
  policy = data.aws_iam_policy_document.secrets_access.json
}

resource "aws_iam_role_policy_attachment" "secrets_access" {
  role       = aws_iam_role.external_secrets.name
  policy_arn = aws_iam_policy.secrets_access.arn
}

resource "helm_release" "external_secrets" {
  name             = "external-secrets"
  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  namespace        = local.namespace
  create_namespace = true
  timeout          = 600

  set {
    name  = "installCRDs"
    value = "true"
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = local.service_account
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.external_secrets.arn
  }
}

resource "kubernetes_manifest" "cluster_secret_store" {
  manifest = {
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ClusterSecretStore"
    metadata = {
      name = "aws-secrets-manager"
    }
    spec = {
      provider = {
        aws = {
          service = "SecretsManager"
          region  = var.region
          auth = {
            jwt = {
              serviceAccountRef = {
                name      = local.service_account
                namespace = local.namespace
              }
            }
          }
        }
      }
    }
  }

  depends_on = [helm_release.external_secrets]
}

resource "kubernetes_manifest" "catalog_external_secret" {
  manifest = {
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "catalog-db"
      namespace = "retail-app"
    }
    spec = {
      refreshInterval = "1h"
      secretStoreRef = {
        kind = "ClusterSecretStore"
        name = kubernetes_manifest.cluster_secret_store.manifest.metadata.name
      }
      target = {
        name = "catalog-db"
      }
      data = [
        { secretKey = "username", remoteRef = { key = "project-bedrock/catalog-db", property = "username" } },
        { secretKey = "password", remoteRef = { key = "project-bedrock/catalog-db", property = "password" } },
        { secretKey = "endpoint", remoteRef = { key = "project-bedrock/catalog-db", property = "endpoint" } },
        { secretKey = "port", remoteRef = { key = "project-bedrock/catalog-db", property = "port" } },
        { secretKey = "database", remoteRef = { key = "project-bedrock/catalog-db", property = "database" } }
      ]
    }
  }

  depends_on = [helm_release.external_secrets]
}

resource "kubernetes_manifest" "orders_external_secret" {
  manifest = {
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "orders-db"
      namespace = "retail-app"
    }
    spec = {
      refreshInterval = "1h"
      secretStoreRef = {
        kind = "ClusterSecretStore"
        name = kubernetes_manifest.cluster_secret_store.manifest.metadata.name
      }
      target = {
        name = "orders-db"
      }
      data = [
        { secretKey = "username", remoteRef = { key = "project-bedrock/orders-db", property = "username" } },
        { secretKey = "password", remoteRef = { key = "project-bedrock/orders-db", property = "password" } },
        { secretKey = "endpoint", remoteRef = { key = "project-bedrock/orders-db", property = "endpoint" } },
        { secretKey = "port", remoteRef = { key = "project-bedrock/orders-db", property = "port" } },
        { secretKey = "database", remoteRef = { key = "project-bedrock/orders-db", property = "database" } }
      ]
    }
  }

  depends_on = [helm_release.external_secrets]
}
############################
# External Secrets Operator + IRSA
############################
variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "oidc_provider_arn" {
  description = "OIDC provider ARN"
  type        = string
}

variable "oidc_provider_url" {
  description = "OIDC provider URL"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "namespace" {
  description = "Namespace for retail app secrets"
  type        = string
  default     = "retail-app"
}

variable "mysql_secret_arn" {
  description = "Secrets Manager ARN for catalog DB"
  type        = string
}

variable "postgres_secret_arn" {
  description = "Secrets Manager ARN for orders DB"
  type        = string
}

data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "this" {
  name = var.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes = {
    host                   = data.aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

data "aws_iam_policy_document" "external_secrets_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(var.oidc_provider_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:external-secrets:external-secrets"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(var.oidc_provider_url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "external_secrets" {
  name               = "bedrock-external-secrets"
  assume_role_policy = data.aws_iam_policy_document.external_secrets_assume.json
}

data "aws_iam_policy_document" "external_secrets_access" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]
    resources = [
      var.mysql_secret_arn,
      var.postgres_secret_arn
    ]
  }
}

resource "aws_iam_role_policy" "external_secrets_access" {
  name   = "bedrock-external-secrets-access"
  role   = aws_iam_role.external_secrets.id
  policy = data.aws_iam_policy_document.external_secrets_access.json
}

resource "helm_release" "external_secrets" {
  name             = "external-secrets"
  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  namespace        = "external-secrets"
  create_namespace = true
  timeout          = 600

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = "external-secrets"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.external_secrets.arn
  }

  depends_on = [aws_iam_role_policy.external_secrets_access]
}

resource "kubernetes_manifest" "secrets_store" {
  manifest = {
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ClusterSecretStore"
    metadata = {
      name = "aws-secrets"
    }
    spec = {
      provider = {
        aws = {
          service = "SecretsManager"
          region  = var.region
          auth = {
            jwt = {
              serviceAccountRef = {
                name      = "external-secrets"
                namespace = "external-secrets"
              }
            }
          }
        }
      }
    }
  }

  depends_on = [helm_release.external_secrets]
}

resource "kubernetes_manifest" "catalog_db" {
  manifest = {
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "catalog-db"
      namespace = var.namespace
    }
    spec = {
      refreshInterval = "1h"
      secretStoreRef = {
        name = "aws-secrets"
        kind = "ClusterSecretStore"
      }
      target = {
        name = "catalog-db"
      }
      data = [
        {
          secretKey = "RETAIL_CATALOG_PERSISTENCE_USER"
          remoteRef = {
            key      = var.mysql_secret_arn
            property = "username"
          }
        },
        {
          secretKey = "RETAIL_CATALOG_PERSISTENCE_PASSWORD"
          remoteRef = {
            key      = var.mysql_secret_arn
            property = "password"
          }
        }
      ]
    }
  }

  depends_on = [kubernetes_manifest.secrets_store]
}

resource "kubernetes_manifest" "orders_db" {
  manifest = {
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "orders-db"
      namespace = var.namespace
    }
    spec = {
      refreshInterval = "1h"
      secretStoreRef = {
        name = "aws-secrets"
        kind = "ClusterSecretStore"
      }
      target = {
        name = "orders-db"
      }
      data = [
        {
          secretKey = "RETAIL_ORDERS_PERSISTENCE_USERNAME"
          remoteRef = {
            key      = var.postgres_secret_arn
            property = "username"
          }
        },
        {
          secretKey = "RETAIL_ORDERS_PERSISTENCE_PASSWORD"
          remoteRef = {
            key      = var.postgres_secret_arn
            property = "password"
          }
        }
      ]
    }
  }

  depends_on = [kubernetes_manifest.secrets_store]
}
