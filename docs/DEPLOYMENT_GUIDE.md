# Project Bedrock — Deployment Guide

---

## Quick Navigation

| Section | Description |
|---------|-------------|
| [1. Pipeline Triggers](#1-how-to-trigger-the-pipeline) | How to run CI/CD workflows |
| [2. Retail Store URL](#2-retail-store-application-url) | Access the running application |
| [3. Grading Credentials](#3-grading-credentials-barakat-2025-capstone-bedrock-dev-view) | Access Key and Secret Key for grading |

---

## 1. How to Trigger the Pipeline

### Overview

The repository uses GitHub Actions for Terraform plan, apply, and validation. Pipelines are defined in `.github/workflows/`.

### Pipeline Workflows

| Workflow | Trigger | Actions |
|----------|---------|---------|
| **Terraform Plan & Validation** | Pull request to `infra/**` or workflow file | `terraform fmt`, `validate`, `tflint`, `plan` |
| **Terraform Apply** | Push to `main` (infra changes) | `terraform init`, `terraform apply -auto-approve` |
| **Terraform (dev)** | Manual | `terraform init`, `validate`, `plan` |
| **Terraform (staging)** | Manual | Same as dev |
| **Terraform (prod)** | Manual | Same as dev |

---

### 1.1 Automatic Triggers

#### Terraform Plan (on Pull Request)

**Trigger:** Create or update a pull request that changes:

- Any file under `infra/**`
- `.github/workflows/terraform-plan.yml`

```bash
# Create a branch, make changes, open PR
git checkout -b my-infra-change
# Edit files in infra/
git add infra/
git commit -m "Update infrastructure"
git push origin my-infra-change
# Open PR on GitHub → Plan workflow runs automatically
```

**What runs:** Format check, validate, TFLint, and `terraform plan` for dev, staging, and prod.

---

#### Terraform Apply (on Push to Main)

**Trigger:** Push directly to `main` (or merge a PR) that changes:

- Any file under `infra/**`
- `.github/workflows/terraform-apply.yml`

```bash
# After merge or direct push to main
git checkout main
git pull
# Ensure infra/ has changes
git add infra/  # (if you have local changes)
git commit -m "Deploy infrastructure"
git push origin main
```

**What runs:** `terraform init` and `terraform apply -auto-approve` for the dev environment.

---

### 1.2 Manual Triggers (workflow_dispatch)

For **Terraform (dev)**, **Terraform (staging)**, or **Terraform (prod)**:

1. Open the repository on GitHub.
2. Go to **Actions**.
3. Select the workflow (e.g. **Terraform (dev)**).
4. Click **Run workflow**.
5. Choose branch (usually `main`).
6. Click **Run workflow**.

![Manual workflow run](https://docs.github.com/assets/cb-33638/mw-1440/workflow-dispatch.webp)

---

### 1.3 Prerequisites for CI/CD

Before pipelines can run successfully:

1. **GitHub secrets**
   - Configure `AWS_ROLE_ARN` in the repository for OIDC/federated AWS credentials.
   - Path: **Settings → Secrets and variables → Actions**.

2. **Lambda package (for Apply)**
   - The Terraform Apply workflow uses `lambda/hello/build/handler.zip`.
   - This file must exist before pushing infra changes. Run locally:

   ```bash
   bash scripts/package_lambda_handler.sh
   git add lambda/hello/build/handler.zip
   git commit -m "Add Lambda package for deployment"
   git push origin main
   ```

   Alternatively, add a **Package Lambda** step to the apply workflow before `terraform apply`.

---

### 1.4 Summary: Triggering a Full Deployment

```bash
# 1. Package Lambda (required before apply)
bash scripts/package_lambda_handler.sh

# 2. Commit and push to main (triggers Apply)
git add -A
git commit -m "Deploy Project Bedrock infrastructure"
git push origin main

# 3. Monitor in GitHub Actions
# Actions tab → Terraform Apply → View run
```

---

### 1.5 One-Command Full Stack Deployment

After configuring AWS credentials (`aws configure`), run:

**Windows (PowerShell):**
```powershell
.\scripts\deploy_full_stack.ps1
```

**WSL / Linux:**
```bash
bash scripts/deploy_full_stack.sh
```

This script bootstraps S3+DynamoDB, packages Lambda, and runs `terraform init`, `plan`, and `apply`. Allow 20–30 minutes for completion.

---

## 2. Retail Store Application URL

### How to Obtain the URL

The Retail Store UI is exposed via an Application Load Balancer (ALB) created by the AWS Load Balancer Controller. The DNS name is assigned after the Ingress is provisioned.

#### Step 1: Configure kubectl

```bash
aws eks update-kubeconfig --region us-east-1 --name barakat-2025-capstone-bedrock-cluster
```

#### Step 2: Retrieve the Ingress Address

```bash
kubectl get ingress -n retail-app -w
```

Expected output (once ALB is ready):

```
NAME              CLASS   HOSTS   ADDRESS                                              PORTS   AGE
retail-store-ui   alb     *       k8s-retail-xxxxx-xxxxxxxxxx-xxxxxxxx.elb.amazonaws.com   80      10m
```

#### Step 3: Access the Application

Open the **ADDRESS** value in a browser:

```
http://k8s-retail-xxxxx-xxxxxxxxxx-xxxxxxxx.us-east-1.elb.amazonaws.com
```

- Protocol: **HTTP** (port 80)
- No authentication required for the UI
- The ALB may take **5–15 minutes** after deployment to become fully available

---

### If the ADDRESS Column Is Empty

1. Confirm the ALB controller is running:

   ```bash
   kubectl get pods -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller
   ```

2. Confirm the `retail-store-ui` service exists:

   ```bash
   kubectl get svc -n retail-app
   ```

3. Describe the Ingress for events:

   ```bash
   kubectl describe ingress retail-store-ui -n retail-app
   ```

---

### URL Format Reference

| Component | Value |
|-----------|-------|
| Protocol | `http://` |
| Host | `k8s-retail-<ingress>-<random>.us-east-1.elb.amazonaws.com` |
| Port | 80 (default) |
| Region | us-east-1 |

---

## 3. Grading Credentials (barakat-2025-capstone-bedrock-dev-view)

The IAM user **barakat-2025-capstone-bedrock-dev-view** is provisioned by Terraform (RBAC module) and has read-only AWS access plus EKS view and S3 PutObject for the assets bucket.

### Retrieving Access Key and Secret Key

#### Option A: Terraform Output (CLI)

```bash
cd infra/envs/dev
terraform output bedrock_dev_view_access_key_id
terraform output bedrock_dev_view_secret_access_key
```

#### Option B: Grading JSON File (Makefile)

```bash
make output-dev
```

This writes all outputs to `infra/grading.json`, including the credentials.

```bash
# View the JSON (credentials are in plain text; run from repo root)
cat infra/grading.json | jq -r '.bedrock_dev_view_access_key_id.value, .bedrock_dev_view_secret_access_key.value'
```

#### Option C: Extract for Grading Submission

```bash
cd infra/envs/dev
terraform output -json | jq -r '{
  bedrock_dev_view_access_key_id: .bedrock_dev_view_access_key_id.value,
  bedrock_dev_view_secret_access_key: .bedrock_dev_view_secret_access_key.value
}'
```

---

### Grading Credentials Format

| Field | Description | Example |
|-------|-------------|---------|
| **Access Key ID** | `bedrock_dev_view_access_key_id` | `AKIA...` (20 characters) |
| **Secret Access Key** | `bedrock_dev_view_secret_access_key` | `wJalr...` (40 characters) |

---

### Using the Credentials

```bash
aws configure --profile barakat-2025-capstone-bedrock-dev-view
# AWS Access Key ID: [paste Access Key ID]
# AWS Secret Access Key: [paste Secret Access Key]
# Default region: us-east-1

# Verify
aws sts get-caller-identity --profile barakat-2025-capstone-bedrock-dev-view
aws eks describe-cluster --name barakat-2025-capstone-bedrock-cluster --region us-east-1 --profile barakat-2025-capstone-bedrock-dev-view
```

---

### Permissions

| Service | Permission |
|---------|------------|
| AWS (general) | ReadOnlyAccess |
| EKS | DescribeCluster for barakat-2025-capstone-bedrock-cluster |
| S3 | PutObject, PutObjectAcl on barakat-2025-capstone-bedrock-assets-0347 |

---

## Deployment Checklist Summary

| # | Task | Command or Action |
|---|------|-------------------|
| 1 | Trigger pipeline | Push to `main` (Apply) or open PR (Plan) or run workflow manually |
| 2 | Get Retail Store URL | `kubectl get ingress -n retail-app` → use ADDRESS column |
| 3 | Get grading credentials | `terraform output bedrock_dev_view_access_key_id` and `bedrock_dev_view_secret_access_key` (from `infra/envs/dev`) |

---

## Advisory: Tool Comparison

### Can these resources be provisioned using Terraform, Docker, or Kubernetes?

| Tool | EKS Cluster | VPC | S3 | Lambda | IAM User | Namespace |
|------|-------------|-----|-----|--------|----------|-----------|
| **Terraform** | ✅ Yes (via AWS provider) | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ⚠️ Partial (requires kubectl/manifests) |
| **Docker** | ❌ No | ❌ No | ❌ No | ❌ No | ❌ No | ❌ No |
| **Kubernetes** | ❌ No (runs *on* EKS) | ❌ No | ❌ No | ❌ No | ❌ No | ✅ Yes (retail-app) |

### Recommendation: **Terraform** (Primary) + **Kubernetes** (Workloads)

- **Terraform** — Provision and manage AWS infrastructure: VPC, EKS cluster, S3, Lambda, IAM. Infrastructure as Code (IaC) with state tracking and drift detection.
- **Docker** — Build and package container images (used by Kubernetes manifests); does not provision cloud resources.
- **Kubernetes** — Orchestrate workloads *inside* the EKS cluster (e.g., `retail-app` namespace); does not create the cluster itself.

---

## Resource Nomenclature (Mandatory)

All resources adhere to these conventions:

| Resource | Value |
|----------|-------|
| AWS Region | `us-east-1` (N. Virginia) |
| EKS Cluster Name | `barakat-2025-capstone-bedrock-cluster` |
| VPC Name Tag | `barakat-2025-capstone-bedrock-vpc` |
| Application Namespace | `retail-app` |
| IAM User (Developer) | `barakat-2025-capstone-bedrock-dev-view` |
| S3 Bucket (Assets) | `barakat-2025-capstone-bedrock-assets-0347` |
| Lambda Function | `barakat-2025-capstone-bedrock-asset-processor` |
| Resource Tag | `Project: barakat-2025-capstone` |
| EKS Version | `>= 1.34` |

### Root Module Outputs (Mandatory)

- `cluster_endpoint`
- `cluster_name`
- `region`
- `vpc_id`
- `assets_bucket_name`

---

## Prerequisites (WSL / Ubuntu)

### 1. Install WSL (if not already)

```bash
# From Windows PowerShell (Admin)
wsl --install -d Ubuntu
# Restart if prompted
```

### 2. Install Tools

```bash
# Update packages
sudo apt update && sudo apt upgrade -y

# Terraform (>= 1.5.0)
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install -y terraform

# AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip && sudo ./aws/install && rm -rf aws awscliv2.zip

# kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl && sudo mv kubectl /usr/local/bin/

# zip (for Lambda packaging)
sudo apt install -y zip unzip
```

### 3. Configure AWS CLI

```bash
aws configure
# AWS Access Key ID: [your access key]
# AWS Secret Access Key: [your secret key]
# Default region: us-east-1
# Default output format: json
```

Verify:

```bash
aws sts get-caller-identity
aws eks list-clusters --region us-east-1
```

---

## Bootstrap: S3 Backend and DynamoDB Lock

Create the Terraform state backend and DynamoDB lock table **before** first `terraform apply`:

```bash
# S3 bucket for Terraform state
aws s3api create-bucket \
  --bucket barakat-2025-capstone-tf-state \
  --region us-east-1

aws s3api put-bucket-versioning \
  --bucket barakat-2025-capstone-tf-state \
  --versioning-configuration Status=Enabled

# DynamoDB table for state locking
aws dynamodb create-table \
  --table-name barakat-2025-capstone-tf-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1
```

---

## Step-by-Step Deployment

### 1. Clone the Repository

```bash
cd ~
git clone https://github.com/captainphilips/Capstone-Project-Bedrock.git
cd Capstone-Project-Bedrock
```

### 2. Package the Lambda Function

```bash
# From repo root
bash scripts/package_lambda_handler.sh
# Or: make package-lambda
# Creates: lambda/hello/build/handler.zip
ls -la lambda/hello/build/handler.zip
```

### 3. Initialize Terraform (Dev)

```bash
cd infra/envs/dev
terraform init
```

### 4. Plan

```bash
terraform plan -out=tfplan
```

### 5. Apply

```bash
terraform apply tfplan
# Or: terraform apply -auto-approve
```

Duration: ~15–25 minutes for EKS cluster + node groups.

### 6. Verify Outputs

```bash
terraform output
# Required outputs:
# - cluster_endpoint
# - cluster_name
# - region
# - vpc_id
# - assets_bucket_name
```

### 7. Configure kubectl for EKS

```bash
aws eks update-kubeconfig \
  --region us-east-1 \
  --name barakat-2025-capstone-bedrock-cluster

kubectl get nodes
kubectl get namespaces
# Expect: retail-app (and kube-system, etc.)
```

---

## Quick Reference Commands

| Action | Command |
|--------|---------|
| Plan (dev) | `cd infra/envs/dev && terraform plan -out=tfplan` |
| Apply (dev) | `cd infra/envs/dev && terraform apply tfplan` |
| Outputs | `cd infra/envs/dev && terraform output -json > ../../grading.json` |
| EKS kubeconfig | `aws eks update-kubeconfig --region us-east-1 --name barakat-2025-capstone-bedrock-cluster` |
| Lambda package | `bash scripts/package_lambda_handler.sh` |

---

## Troubleshooting

### S3 bucket name already taken

S3 bucket names are globally unique. If `barakat-2025-capstone-bedrock-assets-0347` exists, append a unique suffix (e.g., AWS account ID) and update `infra/envs/dev/main.tf`:

```hcl
assets_bucket_name = "barakat-2025-capstone-bedrock-assets-0347-YOUR_ACCOUNT_ID"
```

### Lambda apply fails: "file not found"

Ensure the Lambda zip exists before apply:

```bash
bash scripts/package_lambda_handler.sh
ls lambda/hello/build/handler.zip
```

### EKS node group not ready

Wait for nodes to join (up to 5–10 minutes):

```bash
kubectl get nodes -w
```

### Access denied to EKS

Use IAM user `barakat-2025-capstone-bedrock-dev-view` credentials and run `aws eks update-kubeconfig` after the user is granted access via Terraform RBAC.

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                        us-east-1                                 │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ barakat-2025-capstone-bedrock-vpc (10.0.0.0/16)                        │   │
│  │  ┌─────────────────┐    ┌─────────────────────────────┐  │   │
│  │  │ Public Subnets   │    │ Private Subnets (EKS)       │  │   │
│  │  │ + NAT Gateway   │    │ barakat-2025-capstone-bedrock-cluster     │  │   │
│  │  └─────────────────┘    │ - retail-app namespace     │  │   │
│  │                          └─────────────────────────────┘  │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                  │
│  barakat-2025-capstone-bedrock-assets-0347 ──► barakat-2025-capstone-bedrock-asset-processor       │
│  IAM: barakat-2025-capstone-bedrock-dev-view                                           │
└─────────────────────────────────────────────────────────────────┘
```
