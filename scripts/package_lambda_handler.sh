#!/bin/bash

set -e

echo "Packaging Lambda function..."
echo ""

# Navigate to the lambda directory
cd lambda/hello

# Create the zip file
mkdir -p build
zip -j build/handler.zip handler.py

echo ""
echo "✅ Lambda function packaged successfully"
echo ""
echo "Output: lambda/hello/build/handler.zip"
echo ""
echo "This file is referenced by Terraform as the Lambda deployment package."
