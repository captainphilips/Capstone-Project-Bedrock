#!/bin/bash
# Package Lambda - run from project root or any subdirectory.
# Usage: bash package_lambda.sh   OR   bash /path/to/package_lambda.sh

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"
exec bash scripts/package_lambda_handler.sh
