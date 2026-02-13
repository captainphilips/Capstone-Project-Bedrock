# Lambda Functions

AWS Lambda functions for Project Bedrock.

## barakat-2025-capstone-bedrock-asset-processor

**Path**: `hello/`  
**Function name**: `barakat-2025-capstone-bedrock-asset-processor`  
**Trigger**: S3 events on `barakat-2025-capstone-bedrock-assets-0347` bucket  
**Runtime**: Python 3.10

### Build

```bash
# From repo root (recommended)
cd ~/Capstone-Project-Bedrock
python3 scripts/package_lambda_handler.py
# or
bash scripts/package_lambda_handler.sh

# From any subdirectory (e.g. infra/envs/dev)
bash ../../package_lambda.sh
# or
python3 ../../scripts/package_lambda_handler.py
```

Output: `lambda/hello/build/handler.zip` — referenced by Terraform. Ensure it exists before `terraform apply`.

### Test

```bash
# After deployment - upload to S3 to trigger Lambda
bash scripts/test_lambda.sh

# View logs
aws logs tail /aws/lambda/barakat-2025-capstone-bedrock-asset-processor --region us-east-1 --follow
```
