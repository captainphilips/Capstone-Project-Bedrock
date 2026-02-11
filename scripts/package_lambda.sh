#!/bin/bash
# Package Lambda function - delegates to package_lambda_handler.sh
# Kept for Makefile compatibility. Use scripts/package_lambda_handler.sh directly.

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR/.."
bash scripts/package_lambda_handler.sh
