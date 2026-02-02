#!/bin/bash
# Package Lambda function into a deployable zip file

set -e

LAMBDA_DIR="services/lambda"
SRC_DIR="$LAMBDA_DIR/src"
BUILD_DIR="$LAMBDA_DIR/build"
REQUIREMENTS="$LAMBDA_DIR/requirements.txt"
OUTPUT_ZIP="$BUILD_DIR/handler.zip"

echo "Packaging Lambda function..."

# Create build directory
mkdir -p "$BUILD_DIR"

# Create temporary working directory
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

echo "Installing dependencies..."
pip install -q -r "$REQUIREMENTS" -t "$TEMP_DIR"

echo "Adding source code..."
cp "$SRC_DIR/handler.py" "$TEMP_DIR/"

echo "Creating zip archive..."
cd "$TEMP_DIR"
zip -q -r "$OUTPUT_ZIP" .
cd -

echo "Lambda package created: $OUTPUT_ZIP"
ls -lh "$OUTPUT_ZIP"
