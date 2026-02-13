#!/bin/bash
# Terraform apply wrapper for environment selection

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

if [ ! -f "$ENVS_DIR/$ENV/tfplan" ]; then
  echo "No plan file found. Run: ./scripts/tf_plan.sh $ENV"
  exit 1
fi

echo "WARNING: This will apply changes to $ENV infrastructure"
read -p "Are you sure? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
  echo "Aborted"
  exit 0
fi

echo "Applying $ENV infrastructure..."
cd "$ENVS_DIR/$ENV"
terraform apply -input=false tfplan

echo ""
echo "Apply complete for $ENV"
terraform output -json > ../../../grading.json
echo "Outputs saved to grading.json"
