#!/bin/bash
# Verify CloudWatch metrics and Container Insights for project-bedrock-cluster

set -e
REGION="us-east-1"
CLUSTER="project-bedrock-cluster"

echo "=========================================="
echo "Verifying CloudWatch Metrics"
echo "=========================================="
echo ""

echo "Container Insights log groups:"
aws logs describe-log-groups \
  --log-group-name-prefix "/aws/containerinsights/${CLUSTER}" \
  --region "$REGION" \
  --query 'logGroups[].logGroupName' \
  --output text 2>/dev/null | tr '\t' '\n' || echo "  (none yet - addon may still be installing)"

echo ""
echo "EKS control plane log groups:"
aws logs describe-log-groups \
  --log-group-name-prefix "/aws/eks/${CLUSTER}" \
  --region "$REGION" \
  --query 'logGroups[].logGroupName' \
  --output text 2>/dev/null | tr '\t' '\n' || echo "  (none found)"

echo ""
echo "=========================================="
echo "Container Insights Console"
echo "=========================================="
echo ""
echo "https://console.aws.amazon.com/cloudwatch/home?region=${REGION}#container-insights:infrastructure"
echo ""
