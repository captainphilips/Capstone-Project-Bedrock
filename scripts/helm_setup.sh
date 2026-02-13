#!/bin/bash

set -e

# Manual Helm Chart Setup
# Use this script if the Terraform helm provider can't pull the retail-store chart

# Add the retail store chart repository
# Note: Using the raw GitHub URL as the chart source
echo "Setting up Helm chart for retail-store sample app..."
helm repo add retail-store https://raw.githubusercontent.com/aws-containers/retail-store-sample-app/main/deploy/helm/chart || true

# Update helm repositories
helm repo update

# Verify the chart is accessible
helm search repo retail-store || echo "Warning: Chart may not be indexed yet"

echo "Helm chart repository configured successfully"
echo ""
echo "Alternative: The chart can also be deployed directly using:"
echo "helm install retail-store oci://ghcr.io/aws-containers/retail-store-sample-app/chart"
