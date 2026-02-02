resource "kubernetes_cluster_role_binding" "dev_view" {
  metadata {
    name = "bedrock-dev-view-binding"
  }

  # Bind to the built-in "view" ClusterRole
  # This grants: get, list, watch on almost all resources — but NO create/update/delete
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "view"
  }

  # Subject = the custom group we mapped in aws-auth
  subject {
    kind      = "Group"
    name      = "dev-viewers"
    api_group = "rbac.authorization.k8s.io"
  }

  # Note: depends_on references modules - ensure this is called after EKS and IAM modules
  # depends_on = [aws_eks_cluster.bedrock, kubernetes_config_map_v1_data.aws_auth]
}
