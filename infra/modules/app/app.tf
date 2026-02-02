resource "kubernetes_namespace" "retail_app" {
  metadata {
    name = "retail-app"
    labels = {
      Project = "Bedrock"
    }
  }
}

resource "helm_release" "retail_store" {
  name      = "retail-store"
  namespace = kubernetes_namespace.retail_app.metadata[0].name
  repository = "https://charts.github.com/aws-retail-store-sample-app"

  # If the above chart repo doesn't resolve, use:
  # chart = "https://raw.githubusercontent.com/aws-containers/retail-store-sample-app/main/deploy/helm/chart"
  # Otherwise:
  chart   = "retail-store"
  version = "0.1.0"

  # Use default values — this gives us in-cluster MySQL, Postgres,
  # RabbitMQ, Redis, and DynamoDB Local automatically.
  wait    = true
  timeout = 600

  # Removed invalid cross-module dependency
  # depends_on = [aws_eks_node_group.bedrock]
}
