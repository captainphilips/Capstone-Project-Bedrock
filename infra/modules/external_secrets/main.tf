terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source                = "hashicorp/kubernetes"
      version               = "~> 3.0"
      configuration_aliases = [kubernetes]
    }
    helm = {
      source                = "hashicorp/helm"
      version               = "~> 3.0"
      configuration_aliases = [helm]
    }
  }
}

# Uses kubernetes/helm providers passed from root

locals {
  namespace       = "external-secrets"
  service_account = "external-secrets"
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
  name               = "barakat-2025-capstone-external-secrets-role"
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
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
    resources = [var.mysql_secret_arn, var.postgres_secret_arn]
  }
}

resource "aws_iam_policy" "secrets_access" {
  name   = "barakat-2025-capstone-secrets-access"
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

  set = [
    { name = "installCRDs", value = "true" },
    { name = "serviceAccount.create", value = "true" },
    { name = "serviceAccount.name", value = local.service_account },
    { name = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn", value = aws_iam_role.external_secrets.arn }
  ]
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
      namespace = var.namespace
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
        { secretKey = "username", remoteRef = { key = "barakat-2025-capstone/catalog-db", property = "username" } },
        { secretKey = "password", remoteRef = { key = "barakat-2025-capstone/catalog-db", property = "password" } },
        { secretKey = "endpoint", remoteRef = { key = "barakat-2025-capstone/catalog-db", property = "endpoint" } },
        { secretKey = "port", remoteRef = { key = "barakat-2025-capstone/catalog-db", property = "port" } },
        { secretKey = "database", remoteRef = { key = "barakat-2025-capstone/catalog-db", property = "database" } }
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
      namespace = var.namespace
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
        { secretKey = "username", remoteRef = { key = "barakat-2025-capstone/orders-db", property = "username" } },
        { secretKey = "password", remoteRef = { key = "barakat-2025-capstone/orders-db", property = "password" } },
        { secretKey = "endpoint", remoteRef = { key = "barakat-2025-capstone/orders-db", property = "endpoint" } },
        { secretKey = "port", remoteRef = { key = "barakat-2025-capstone/orders-db", property = "port" } },
        { secretKey = "database", remoteRef = { key = "barakat-2025-capstone/orders-db", property = "database" } }
      ]
    }
  }

  depends_on = [helm_release.external_secrets]
}
