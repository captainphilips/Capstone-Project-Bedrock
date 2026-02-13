#!/bin/bash
# Test Lambda function (barakat-2025-capstone-bedrock-asset-processor) via S3 upload simulation
# Requires: AWS CLI, Lambda deployed, S3 bucket accessible
# Usage: bash scripts/test_lambda.sh [bucket-name]

set -e
BUCKET="${1:-$(cd "$(dirname "$0")/.." && terraform -chdir=infra/envs/dev output -raw assets_bucket_name 2>/dev/null || echo "barakat-2025-capstone-bedrock-assets-0347")}"

echo "Testing Lambda (barakat-2025-capstone-bedrock-asset-processor) via S3 trigger..."
echo "Bucket: $BUCKET"
echo ""

# Create a test file and upload
TEST_FILE="/tmp/lambda-test-$(date +%s).txt"
echo "Lambda test at $(date)" > "$TEST_FILE"

if aws s3 cp "$TEST_FILE" "s3://$BUCKET/test/lambda-test.txt" 2>/dev/null; then
  echo "✓ Uploaded test file to s3://$BUCKET/test/lambda-test.txt"
  echo "  Lambda should be invoked. Check CloudWatch: /aws/lambda/barakat-2025-capstone-bedrock-asset-processor"
  rm -f "$TEST_FILE"
else
  echo "✗ Upload failed. Ensure AWS credentials and S3 access are configured."
  rm -f "$TEST_FILE"
  exit 1
fi
