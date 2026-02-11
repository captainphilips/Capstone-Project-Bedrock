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
BUCKET="project-bedrock-0347-tf-state"
TABLE="project-bedrock-tf-lock"
REGION="us-east-1"

if ! aws s3api head-bucket --bucket "$BUCKET" --region "$REGION" 2>/dev/null; then
    echo "  Creating S3 bucket..."
    aws s3api create-bucket --bucket "$BUCKET" --region "$REGION"
    aws s3api put-bucket-versioning --bucket "$BUCKET" --versioning-configuration Status=Enabled
    echo "  S3 bucket created"
else
    echo "  S3 bucket exists"
fi

if ! aws dynamodb describe-table --table-name "$TABLE" --region "$REGION" 2>/dev/null; then
    echo "  Creating DynamoDB table..."
    aws dynamodb create-table --table-name "$TABLE" \
        --attribute-definitions AttributeName=LockID,AttributeType=S \
        --key-schema AttributeName=LockID,KeyType=HASH \
        --billing-mode PAY_PER_REQUEST \
        --region "$REGION"
    echo "  Waiting for DynamoDB table..."
    sleep 10
    echo "  DynamoDB table ready"
else
    echo "  DynamoDB table exists"
fi

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
