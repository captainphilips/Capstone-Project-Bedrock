#!/usr/bin/env python3
"""
Cross-platform Lambda packaging script.
Creates handler.zip for the barakat-2025-capstone-bedrock-asset-processor Lambda.
Works on Windows, Linux, and macOS without requiring the zip utility.
"""

import os
import sys
import zipfile


def main():
    # Resolve paths relative to this script (works from any cwd)
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.dirname(script_dir)
    lambda_dir = os.path.join(project_root, "lambda", "hello")
    build_dir = os.path.join(lambda_dir, "build")
    handler_py = os.path.join(lambda_dir, "handler.py")
    output_zip = os.path.join(build_dir, "handler.zip")

    if not os.path.exists(handler_py):
        print("Error: handler.py not found at", handler_py, file=sys.stderr)
        sys.exit(1)

    os.makedirs(build_dir, exist_ok=True)

    with zipfile.ZipFile(output_zip, "w", zipfile.ZIP_DEFLATED) as zf:
        zf.write(handler_py, "handler.py")

    print("Packaging Lambda function...")
    print("")
    print("Lambda function packaged successfully")
    print("")
    print("Output:", output_zip)
    print("")
    print("This file is referenced by Terraform as the Lambda deployment package.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
