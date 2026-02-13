#!/bin/bash
# Bootstrap Terraform state backend (S3 + DynamoDB)
# Run once before first terraform apply. Idempotent.

set -e
BUCKET="barakat-2025-capstone-tf-state"
TABLE="barakat-2025-capstone-tf-lock"
REGION="us-east-1"

echo "Bootstrap Terraform state backend..."

if ! aws s3api head-bucket --bucket "$BUCKET" --region "$REGION" 2>/dev/null; then
  aws s3api create-bucket --bucket "$BUCKET" --region "$REGION"
  aws s3api put-bucket-versioning --bucket "$BUCKET" --versioning-configuration Status=Enabled
  echo "  S3 bucket $BUCKET created"
else
  echo "  S3 bucket $BUCKET exists"
fi

if ! aws dynamodb describe-table --table-name "$TABLE" --region "$REGION" 2>/dev/null; then
  aws dynamodb create-table --table-name "$TABLE" \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --region "$REGION"
  echo "  DynamoDB table $TABLE created (waiting for active)..."
  sleep 10
else
  echo "  DynamoDB table $TABLE exists"
fi

echo "Bootstrap complete."
