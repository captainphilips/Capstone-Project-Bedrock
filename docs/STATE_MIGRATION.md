# Terraform State Migration

If you already have Terraform state in the old backend (`project-bedrock-0347-tf-state`), use this guide to migrate to the new naming (`barakat-2025-capstone-tf-state`).

## Quick Migration (Linux/WSL/Git Bash)

```bash
# From repo root
bash scripts/migrate_terraform_state.sh
```

This script will:
1. Create `barakat-2025-capstone-tf-state` S3 bucket and `barakat-2025-capstone-tf-lock` DynamoDB table
2. Copy existing state files (dev, staging, prod) to the new bucket
3. Run `terraform init -migrate-state` so Terraform uses the new backend
4. Verify state is accessible

## Manual Migration

### 1. Create New Backend Resources

```bash
# S3 bucket
aws s3api create-bucket \
  --bucket barakat-2025-capstone-tf-state \
  --region us-east-1

aws s3api put-bucket-versioning \
  --bucket barakat-2025-capstone-tf-state \
  --versioning-configuration Status=Enabled

# DynamoDB table
aws dynamodb create-table \
  --table-name barakat-2025-capstone-tf-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1
```

### 2. Copy State Files

```bash
# Replace with your env keys if different
aws s3 cp s3://project-bedrock-0347-tf-state/dev/terraform.tfstate \
         s3://barakat-2025-capstone-tf-state/dev/terraform.tfstate
```

### 3. Update Backend Config & Migrate

The repo's `backend.tf` files are already updated. Run:

```bash
cd infra/envs/dev
terraform init -migrate-state
```

Answer `yes` when prompted to copy state to the new backend.

### 4. Verify

```bash
terraform state list
terraform plan  # Should show no changes
```

## Fresh Deployment (No Existing State)

If you're starting fresh:

```bash
bash scripts/bootstrap_terraform_state.sh
cd infra/envs/dev
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

Or use `deploy_full_stack.ps1` / `deploy_full_stack.sh` which bootstrap automatically.
