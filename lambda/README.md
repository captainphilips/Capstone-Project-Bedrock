# Lambda Functions

AWS Lambda functions for Project Bedrock.

## bedrock-asset-processor

**Path**: `hello/`  
**Function name**: `bedrock-asset-processor`  
**Trigger**: S3 events on `bedrock-assets-ALTSOE025-0347` bucket  
**Runtime**: Python 3.10

### Build

```bash
# From repo root
bash scripts/package_lambda_handler.sh
# Output: lambda/hello/build/handler.zip
```

The zip is referenced by Terraform (`infra/modules/serverless`). Ensure it exists before `terraform apply`.
