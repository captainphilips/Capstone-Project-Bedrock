################################################################################
# Retail Store Sample App (Helm)
################################################################################
# Uses kubernetes/helm providers passed from root

terraform {
  required_providers {
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

resource "helm_release" "retail_store" {
  name             = "retail-store"
  repository       = "https://aws-samples.github.io/retail-store-sample-app"
  chart            = "retail-store-sample-app"
  namespace        = var.namespace
  create_namespace = true
  timeout          = 600

  values = [
    templatefile("${path.module}/values.tmpl.yaml", {
      catalog_db_endpoint = var.catalog_db_endpoint
      catalog_db_username = var.catalog_db_username
      catalog_db_password = var.catalog_db_password
      orders_db_endpoint  = var.orders_db_endpoint
      orders_db_port      = var.orders_db_port
      orders_db_name      = var.orders_db_name
      orders_db_username  = var.orders_db_username
      orders_db_password  = var.orders_db_password
    })
  ]
}
