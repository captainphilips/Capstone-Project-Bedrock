#!/bin/bash

set -e

cd infra/envs/dev

terraform plan

# This takes ~10-15 minutes for EKS
terraform apply -auto-approve

# Once apply is done, update your local kubeconfig:
aws eks update-kubeconfig --name barakat-2025-capstone-bedrock-cluster --region us-east-1

# Verify cluster access:
kubectl get nodes
