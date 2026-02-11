#!/bin/bash
# Project Bedrock - Full Stack Deployment Script (WSL/Linux)
# Run: bash scripts/deploy_full_stack.sh

set -e
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

echo ""
echo "=== Project Bedrock Full Stack Deployment ==="
echo ""

# 1. Check AWS credentials
echo "[1/6] Checking AWS credentials..."
if ! aws sts get-caller-identity >/dev/null 2>&1; then
    echo "  ERROR: AWS credentials not configured. Run: aws configure"
    exit 1
fi
echo "  OK: AWS credentials valid"

# 2. Bootstrap S3 + DynamoDB
echo ""
echo "[2/6] Bootstrap Terraform state backend..."
bash scripts/bootstrap_terraform_state.sh

# 3. Package Lambda
echo ""
echo "[3/6] Packaging Lambda function..."
bash scripts/package_lambda_handler.sh
echo "  Lambda package ready"

# 4. Terraform Init
echo ""
echo "[4/6] Terraform init..."
cd infra/envs/dev
terraform init -input=false
echo "  Terraform initialized"

# 5. Terraform Plan
echo ""
echo "[5/6] Terraform plan..."
terraform plan -out=tfplan -input=false

# 6. Terraform Apply
echo ""
echo "[6/6] Terraform apply (takes 20-30 minutes)..."
terraform apply -input=false tfplan

echo ""
echo "=== Deployment Complete ==="
echo "Next steps:"
echo "  1. aws eks update-kubeconfig --region us-east-1 --name project-bedrock-cluster"
echo "  2. kubectl get ingress -n retail-app"
echo "  3. terraform output"
echo ""
