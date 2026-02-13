#!/bin/bash

set -e

# Cross-platform: use Python (built-in zipfile) - no zip utility required
# Works on Windows, Linux, macOS. Python is guaranteed (Lambda is Python).
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

if command -v python3 &>/dev/null; then
  python3 scripts/package_lambda_handler.py
elif command -v python &>/dev/null; then
  python scripts/package_lambda_handler.py
else
  echo "Error: Python is required to package the Lambda. Install Python and try again." >&2
  exit 1
fi
