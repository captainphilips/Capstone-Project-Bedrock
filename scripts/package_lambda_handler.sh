#!/bin/bash

set -e

echo "Packaging Lambda function..."
echo ""

# Navigate to the lambda directory
cd services/lambda/src

# Create the zip file
zip -j ../build/handler.zip handler.py

echo ""
echo "✅ Lambda function packaged successfully"
echo ""
echo "Output: services/lambda/build/handler.zip"
echo ""
echo "This file is referenced by Terraform as the Lambda deployment package."
