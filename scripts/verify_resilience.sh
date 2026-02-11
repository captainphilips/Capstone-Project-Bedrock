#!/bin/bash
# Verify scalability and resilience: nodes, AZs, pod distribution

set -e

echo "=========================================="
echo "Resilience & Scalability Verification"
echo "=========================================="
echo ""

echo "Nodes (expect 2+ across AZs):"
kubectl get nodes -o wide 2>/dev/null || {
  echo "  Run: aws eks update-kubeconfig --region us-east-1 --name project-bedrock-cluster"
  exit 1
}

echo ""
echo "Node distribution by Zone:"
kubectl get nodes -o custom-columns=NAME:.metadata.name,STATUS:.status.conditions[-1].type,ZONE:.metadata.labels.topology\.kubernetes\.io/zone 2>/dev/null || true

echo ""
echo "Retail-app pods (expect Running):"
kubectl get pods -n retail-app -o wide 2>/dev/null || true

echo ""
echo "=========================================="
echo "Scaling test (optional)"
echo "=========================================="
echo ""
echo "kubectl scale deployment retail-store-ui --replicas=2 -n retail-app"
echo ""
