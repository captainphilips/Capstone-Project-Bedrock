#!/bin/bash
# Package Lambda function into a deployable zip file

set -e

LAMBDA_DIR="lambda/hello"
SRC_FILE="$LAMBDA_DIR/handler.py"
BUILD_DIR="$LAMBDA_DIR/build"
REQUIREMENTS="$LAMBDA_DIR/requirements.txt"
OUTPUT_ZIP="$BUILD_DIR/handler.zip"

echo "Packaging Lambda function..."

# Create build directory
mkdir -p "$BUILD_DIR"

# Create temporary working directory
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

if [ -f "$REQUIREMENTS" ]; then
  echo "Installing dependencies..."
  pip install -q -r "$REQUIREMENTS" -t "$TEMP_DIR"
fi

echo "Adding source code..."
cp "$SRC_FILE" "$TEMP_DIR/"

echo "Creating zip archive..."
cd "$TEMP_DIR"
zip -q -r "$OUTPUT_ZIP" .
cd -

echo "Lambda package created: $OUTPUT_ZIP"
ls -lh "$OUTPUT_ZIP"
