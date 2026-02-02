#!/bin/bash
# Terraform initialization wrapper for environment selection

set -e

ENVS_DIR="infra/envs"

echo "Project Bedrock - Terraform Initialization"
echo ""
echo "Available environments:"
echo "  1) dev"
echo "  2) staging"
echo "  3) prod"
echo ""

read -p "Select environment (1-3): " choice

case $choice in
  1) ENV="dev" ;;
  2) ENV="staging" ;;
  3) ENV="prod" ;;
  *) echo "Invalid choice"; exit 1 ;;
esac

echo ""
echo "Initializing $ENV environment..."
cd "$ENVS_DIR/$ENV"
terraform init
echo ""
echo "Initialization complete for $ENV"
echo "You can now run: terraform plan"
