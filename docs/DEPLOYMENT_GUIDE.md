# Project Bedrock — Deployment Guide

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
| EKS Cluster Name | `project-bedrock-cluster` |
| VPC Name Tag | `project-bedrock-vpc` |
| Application Namespace | `retail-app` |
| IAM User (Developer) | `bedrock-dev-view` |
| S3 Bucket (Assets) | `bedrock-assets-ALTSOE025-0347` |
| Lambda Function | `bedrock-asset-processor` |
| Resource Tag | `Project: Bedrock-Terraform` |
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
  --bucket project-bedrock-0347-tf-state \
  --region us-east-1

aws s3api put-bucket-versioning \
  --bucket project-bedrock-0347-tf-state \
  --versioning-configuration Status=Enabled

# DynamoDB table for state locking
aws dynamodb create-table \
  --table-name project-bedrock-tf-lock \
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
  --name project-bedrock-cluster

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
| EKS kubeconfig | `aws eks update-kubeconfig --region us-east-1 --name project-bedrock-cluster` |
| Lambda package | `bash scripts/package_lambda_handler.sh` |

---

## Troubleshooting

### S3 bucket name already taken

S3 bucket names are globally unique. If `bedrock-assets-ALTSOE025-0347` exists, append a unique suffix (e.g., AWS account ID) and update `infra/envs/dev/main.tf`:

```hcl
assets_bucket_name = "bedrock-assets-ALTSOE025-0347-YOUR_ACCOUNT_ID"
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

Use IAM user `bedrock-dev-view` credentials and run `aws eks update-kubeconfig` after the user is granted access via Terraform RBAC.

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                        us-east-1                                 │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ project-bedrock-vpc (10.0.0.0/16)                        │   │
│  │  ┌─────────────────┐    ┌─────────────────────────────┐  │   │
│  │  │ Public Subnets   │    │ Private Subnets (EKS)       │  │   │
│  │  │ + NAT Gateway   │    │ project-bedrock-cluster     │  │   │
│  │  └─────────────────┘    │ - retail-app namespace     │  │   │
│  │                          └─────────────────────────────┘  │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                  │
│  bedrock-assets-ALTSOE025-0347 ──► bedrock-asset-processor       │
│  IAM: bedrock-dev-view                                           │
└─────────────────────────────────────────────────────────────────┘
```
