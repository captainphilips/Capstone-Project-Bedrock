#!/bin/bash
# Diagnose why EKS, Lambda, retail-app are not configured
# Run from anywhere; will cd to infra/envs/dev

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/../infra/envs/dev"

echo "=== Terraform Diagnostic ==="
echo ""
echo "1. State contents (first 60 resources):"
terraform state list 2>/dev/null | head -60

echo ""
echo "2. Modules in main.tf:"
grep "^module " main.tf 2>/dev/null || true

echo ""
echo "3. Plan summary:"
terraform plan -no-color 2>&1 | tail -40
