#!/bin/bash
# Migrate Terraform state from old backend to barakat-2025-capstone-tf-state
# Run from repo root if you have existing state in project-bedrock-0347-tf-state

set -e
OLD_BUCKET="project-bedrock-0347-tf-state"
NEW_BUCKET="barakat-2025-capstone-tf-state"
OLD_TABLE="project-bedrock-tf-lock"
NEW_TABLE="barakat-2025-capstone-tf-lock"
REGION="us-east-1"

echo "=== Terraform State Migration ==="
echo "Old: $OLD_BUCKET / $OLD_TABLE"
echo "New: $NEW_BUCKET / $NEW_TABLE"
echo ""

# 1. Create new backend resources
echo "[1/4] Creating new S3 bucket and DynamoDB table..."
if ! aws s3api head-bucket --bucket "$NEW_BUCKET" --region "$REGION" 2>/dev/null; then
  aws s3api create-bucket --bucket "$NEW_BUCKET" --region "$REGION"
  aws s3api put-bucket-versioning --bucket "$NEW_BUCKET" --versioning-configuration Status=Enabled
  echo "  Created S3 bucket $NEW_BUCKET"
else
  echo "  S3 bucket $NEW_BUCKET exists"
fi

if ! aws dynamodb describe-table --table-name "$NEW_TABLE" --region "$REGION" 2>/dev/null; then
  aws dynamodb create-table --table-name "$NEW_TABLE" \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --region "$REGION"
  echo "  Created DynamoDB table $NEW_TABLE (waiting 10s)..."
  sleep 10
else
  echo "  DynamoDB table $NEW_TABLE exists"
fi

# 2. Copy state files from old bucket to new
echo ""
echo "[2/4] Copying state files..."
for KEY in dev/terraform.tfstate staging/terraform.tfstate prod/terraform.tfstate; do
  if aws s3api head-object --bucket "$OLD_BUCKET" --key "$KEY" --region "$REGION" 2>/dev/null; then
    aws s3 cp "s3://$OLD_BUCKET/$KEY" "s3://$NEW_BUCKET/$KEY" --region "$REGION"
    echo "  Copied $KEY"
  fi
done

# 3. Re-initialize Terraform to use new backend (state already copied)
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
echo ""
echo "[3/4] Re-initializing Terraform (dev)..."
cd "$REPO_ROOT/infra/envs/dev"
terraform init -reconfigure -input=false

echo ""
echo "[4/4] Verifying state..."
terraform state list >/dev/null 2>&1 && echo "  State OK" || echo "  WARNING: state list failed - check manually"

echo ""
echo "=== Migration Complete ==="
echo "Backend now uses: $NEW_BUCKET / $NEW_TABLE"
echo "Old bucket ($OLD_BUCKET) can be emptied after verifying deployment."
echo ""
