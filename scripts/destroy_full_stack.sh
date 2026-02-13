#!/bin/bash
# Project Bedrock - Full Stack Destroy (dev environment)
# Run: bash scripts/destroy_full_stack.sh
# WARNING: Destroys ALL dev infrastructure. Cannot be undone.

set -e
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

echo ""
echo "=== Project Bedrock - Destroy Dev Infrastructure ==="
echo ""
echo "WARNING: This will destroy:"
echo "  - EKS cluster, node groups"
echo "  - VPC, subnets, NAT gateways"
echo "  - RDS (MySQL, Postgres)"
echo "  - Lambda, S3 bucket"
echo "  - Load balancer, ingress"
echo "  - Retail app (Helm releases)"
echo ""
read -p "Continue? Type 'yes' to confirm: " CONFIRM
if [[ "$CONFIRM" != "yes" ]]; then
  echo "Aborted."
  exit 0
fi

echo ""
echo "[1/2] Bootstrap state backend (ensure init works)..."
bash scripts/bootstrap_terraform_state.sh

echo ""
echo "[2/2] Terraform destroy..."
cd infra/envs/dev
terraform init -input=false -reconfigure
terraform destroy -auto-approve -input=false

echo ""
echo "=== Destroy Complete ==="
echo "State remains in S3. To redeploy from scratch, run:"
echo "  bash scripts/deploy_full_stack.sh"
echo ""
