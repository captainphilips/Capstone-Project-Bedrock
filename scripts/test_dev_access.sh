#!/bin/bash

set -e

echo "=========================================="
echo "Testing Developer User Access"
echo "=========================================="
echo ""

# Step 1: Configure AWS profile with dev user credentials
echo "Step 1: Configure AWS profile 'bedrock-dev'"
echo "Run the following command and enter credentials from terraform output:"
echo ""
echo "  aws configure --profile bedrock-dev"
echo ""
echo "When prompted:"
echo "  - AWS Access Key ID: (from: terraform output dev_access_key_id)"
echo "  - AWS Secret Access Key: (from: terraform output dev_secret_access_key)"
echo "  - Default region: us-east-1"
echo "  - Default output format: json"
echo ""
read -p "Press Enter after configuring the profile..."

# Step 2: Update kubeconfig with dev profile
echo ""
echo "Step 2: Updating kubeconfig with dev user profile..."
aws eks update-kubeconfig \
  --name project-bedrock-cluster \
  --region us-east-1 \
  --profile bedrock-dev \
  --alias bedrock-dev

# Step 3: Switch to the new context
echo ""
echo "Step 3: Switching to bedrock-dev context..."
kubectl config use-context bedrock-dev

# Step 4: Test read-only access (should succeed)
echo ""
echo "=========================================="
echo "✅ Testing READ-ONLY Access (should SUCCEED)"
echo "=========================================="
echo ""
echo "Command: kubectl get pods -n retail-app"
echo ""
if kubectl get pods -n retail-app; then
  echo "✅ SUCCESS: Developer can read pods"
else
  echo "❌ FAILED: Developer cannot read pods (unexpected)"
fi

# Step 5: Test write access (should fail)
echo ""
echo "=========================================="
echo "❌ Testing WRITE Access (should FAIL)"
echo "=========================================="
echo ""
echo "Command: kubectl delete pod <pod-name> -n retail-app"
echo ""
echo "Note: Replace <pod-name> with an actual pod name from the output above"
echo "Example: kubectl delete pod retail-store-ui-xxx -n retail-app"
echo ""
echo "Expected result: 'Error from server (Forbidden): ...' "
echo ""
read -p "Press Enter to test delete access (or Ctrl+C to skip)..."

# Get first pod name to test deletion
POD_NAME=$(kubectl get pods -n retail-app -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")

if [ -n "$POD_NAME" ]; then
  echo ""
  echo "Testing deletion of pod: $POD_NAME"
  if kubectl delete pod "$POD_NAME" -n retail-app; then
    echo "❌ UNEXPECTED: Developer was able to delete pod (should have been forbidden)"
  else
    echo "✅ SUCCESS: Delete was forbidden as expected"
  fi
else
  echo "⚠️  No pods found to test deletion"
fi

echo ""
echo "=========================================="
echo "Developer Access Test Complete"
echo "=========================================="
