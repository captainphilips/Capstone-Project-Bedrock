#!/bin/bash

set -e

echo "=========================================="
echo "Verifying CloudWatch Logs"
echo "=========================================="
echo ""

echo "Listing CloudWatch log groups in us-east-1..."
echo ""

aws logs describe-log-groups --region us-east-1 --query 'logGroups[].logGroupName' --output text | tr '\t' '\n'

echo ""
echo "=========================================="
echo "Expected Log Groups"
echo "=========================================="
echo ""
echo "✓ /aws/eks/barakat-2025-capstone-bedrock-cluster/cluster"
echo "  └─ Control plane logs (api, audit, authenticator, controllerManager, scheduler)"
echo ""
echo "✓ /aws/eks/barakat-2025-capstone-bedrock-cluster/containers"
echo "  └─ Application container logs (via CloudWatch Agent)"
echo ""

echo "=========================================="
echo "Log Streams in Control Plane Log Group"
echo "=========================================="
echo ""

if aws logs describe-log-streams --log-group-name /aws/eks/barakat-2025-capstone-bedrock-cluster/cluster --region us-east-1 >/dev/null 2>&1; then
  echo "Log streams found:"
  aws logs describe-log-streams --log-group-name /aws/eks/barakat-2025-capstone-bedrock-cluster/cluster --region us-east-1 --query 'logStreams[].logStreamName' --output text | tr '\t' '\n'
  
  echo ""
  echo "Sample recent logs (last 5 minutes):"
  echo ""
  
  # Get logs from the last 5 minutes
  START_TIME=$(($(date +%s) * 1000 - 300000))
  
  aws logs filter-log-events \
    --log-group-name /aws/eks/barakat-2025-capstone-bedrock-cluster/cluster \
    --start-time "$START_TIME" \
    --region us-east-1 \
    --query 'events[0:10].[timestamp,message]' \
    --output text || echo "No recent logs found"
else
  echo "⚠️  Log group /aws/eks/barakat-2025-capstone-bedrock-cluster/cluster not found yet"
  echo "   This is normal immediately after cluster creation. Logs may take a few minutes to appear."
fi

echo ""
echo "=========================================="
echo "CloudWatch Insights Query (optional)"
echo "=========================================="
echo ""
echo "Run this query in AWS CloudWatch Insights for error analysis:"
echo ""
echo "fields @timestamp, @message"
echo "| filter @message like /error|Error|ERROR|exception/"
echo "| stats count() by @message"
echo ""
echo "URL: https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#logsV2:logs-insights"
