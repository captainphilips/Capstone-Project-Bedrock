# Why EKS, Lambda, and retail-app Are Not Configured

## Symptom

`terraform apply` shows "No changes" and outputs only:
- `nat_gateway_ips`
- `private_subnet_ids`
- `public_subnet_ids`
- `vpc_id`

The expected outputs (`cluster_endpoint`, `cluster_name`, `assets_bucket_name`) are missing.

## Root Cause

**Your Terraform state was created by a different configuration** that only includes the VPC module. The current repo's full configuration (EKS, Lambda, RDS, app, etc.) is not in your state.

Evidence:
- State shows `module.vpc.aws_vpc.bedrock`, `module.vpc.aws_eip.nat["us-east-1a"]` — the repo's VPC module uses `aws_vpc.this` and a single NAT
- Outputs include `nat_gateway_ips`, `private_subnet_ids` — the repo's dev `main.tf` does not output these
- Only VPC resources appear in the refresh — EKS, Lambda, app modules are absent from state

## Fix: Full Apply with Correct Config

### 1. Ensure You Have the Full Configuration

```bash
cd ~/Capstone-Project-Bedrock
git pull origin main
```

### 2. Package Lambda (Required Before Apply)

```bash
python3 scripts/package_lambda_handler.py
ls -la lambda/hello/build/handler.zip
```

### 3. Run Full Deployment from Repo Root

```bash
cd ~/Capstone-Project-Bedrock
bash scripts/deploy_full_stack.sh
```

This will:
- Package Lambda
- Run `terraform init`, `plan`, `apply` in `infra/envs/dev`
- Create EKS, RDS, Lambda, S3, retail-app, ALB, etc. (~25–35 minutes)

### 4. If You See State/Config Mismatch

If Terraform wants to **destroy** the current VPC and **create** a new one (because resource addresses changed), that is expected. The old state came from a different config. You can:

**Option A — Accept the replacement (recommended)**

```bash
cd infra/envs/dev
terraform plan   # Review: expect destroy VPC, create EKS/Lambda/app/etc.
terraform apply -auto-approve
```

**Option B — Fresh start (if plan fails or is confusing)**

```bash
cd infra/envs/dev
terraform destroy -auto-approve   # Remove current VPC-only resources
terraform init
terraform apply -auto-approve     # Creates everything (VPC + EKS + Lambda + app)
```

### 5. Verify After Apply

```bash
terraform output
# Expect: cluster_endpoint, cluster_name, assets_bucket_name, vpc_id, etc.

aws eks update-kubeconfig --region us-east-1 --name barakat-2025-capstone-bedrock-cluster
kubectl get pods -n retail-app
kubectl get ingress -n retail-app
```

## Quick Diagnostic

```bash
cd ~/Capstone-Project-Bedrock/infra/envs/dev

# What is in state?
terraform state list

# What does Terraform want to do?
terraform plan
```

If `state list` shows only `module.vpc.*` and `plan` shows many resources "to add" (EKS, persistence, serverless, app, etc.), run `terraform apply -auto-approve` and wait for it to complete.
