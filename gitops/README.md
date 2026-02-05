# GitOps Layout

This folder contains Kubernetes manifests managed by GitOps tools such as Argo CD.

- `base/` contains shared resources (namespaces, RBAC).
- `overlays/` contains per-environment overlays (dev, staging, prod).
- `argocd/applications/` contains Argo CD Application manifests per environment.
