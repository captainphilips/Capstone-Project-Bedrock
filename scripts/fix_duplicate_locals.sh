#!/bin/bash
# Fix "Duplicate local value definition" - locals belong in locals.tf only
# Run from repo root: bash scripts/fix_duplicate_locals.sh

set -e
DEV_DIR="infra/envs/dev"

cd "$(dirname "$0")/.."

# Fix 1: Remove Main.tf if it exists (wrong casing causes both to load on some systems)
if [[ -f "$DEV_DIR/Main.tf" ]]; then
  echo "Removing duplicate $DEV_DIR/Main.tf (use main.tf)..."
  rm -f "$DEV_DIR/Main.tf"
fi

# Fix 2: Restore clean main.tf from git (removes any accidentally added locals block)
echo "Ensuring main.tf has no locals block (locals are in locals.tf)..."
git checkout -- "$DEV_DIR/main.tf" 2>/dev/null || true

echo "Run: cd $DEV_DIR && terraform validate"
