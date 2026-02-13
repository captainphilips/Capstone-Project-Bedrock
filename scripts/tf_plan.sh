#!/bin/bash
# Terraform plan wrapper for environment selection

set -e

ENVS_DIR="infra/envs"

if [ -z "$1" ]; then
  echo "Usage: $0 <dev|staging|prod>"
  exit 1
fi

ENV=$1

if [ ! -d "$ENVS_DIR/$ENV" ]; then
  echo "Environment '$ENV' not found"
  exit 1
fi

echo "Planning $ENV infrastructure..."
cd "$ENVS_DIR/$ENV"
terraform init -upgrade=false
terraform plan -out=tfplan

echo ""
echo "Plan complete for $ENV"
echo "Review the plan above and run: terraform apply tfplan"
