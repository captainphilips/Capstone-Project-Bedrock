#!/bin/bash

set -euo pipefail

if [ -z "${REPO_URL:-}" ] || [ -z "${TARGET_ENV:-}" ]; then
  echo "Usage: REPO_URL=<git_repo_url> TARGET_ENV=<dev|staging|prod> ./scripts/bootstrap_argocd.sh"
  exit 1
fi

echo "Installing Argo CD..."
kubectl create namespace argocd 2>/dev/null || true
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "Waiting for Argo CD API server..."
kubectl rollout status deployment/argocd-server -n argocd

echo "Creating Argo CD Application for $TARGET_ENV..."
cat <<EOF | kubectl apply -f -
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: bedrock-${TARGET_ENV}
  namespace: argocd
spec:
  project: default
  source:
    repoURL: ${REPO_URL}
    targetRevision: main
    path: gitops/overlays/${TARGET_ENV}
  destination:
    server: https://kubernetes.default.svc
    namespace: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
EOF

echo "Argo CD bootstrap complete."
