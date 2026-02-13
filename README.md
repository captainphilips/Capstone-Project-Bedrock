# Project: barakat-2025-capstone-bedrock

**Mission:** Deploy a secure, scalable, production-ready Kubernetes environment on AWS EKS for the AWS Retail Store Sample Application with full automation, observability, and event-driven architecture.

## Table of Contents

- [Introduction](#1-introduction--company-background)
- [Architecture](#2-architecture)
- [Components](#3-components)
- [Quick Start](#4-quick-start)
- [Application URL](#5-application-url)
- [EKS Cluster Access](#6-eks-cluster-access)
- [Logging & Observability](#7-logging--observability)
- [CI/CD Pipeline](#8-cicd-pipeline)
- [Troubleshooting](#9-troubleshooting)
- [Contributing](#10-contributing)

---

## 1. Introduction & Company Background

InnovateMart is a rapidly growing e-commerce startup focused on redefining the online retail experience. The engineering team has transformed a legacy monolithic application into a cloud-native microservices architecture on **Amazon EKS**.

**Key objectives:** Secure multi-AZ EKS cluster, automated IaC, Retail Store Application deployment, centralized logging/metrics, event-driven Lambda integration, and developer-ready access controls.

---

## 2. Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           AWS Cloud                                       │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │  VPC (barakat-2025-capstone-bedrock-vpc)                                         │  │
│  │  ┌─────────────┐  ┌─────────────────┐  ┌──────────────────────┐   │  │
│  │  │ EKS Cluster │  │ RDS (MySQL +    │  │ S3 + Lambda         │   │  │
│  │  │ project-    │  │ PostgreSQL)     │  │ barakat-2025-capstone-bedrock-asset- │   │  │
│  │  │ bedrock-    │  │ External DB      │  │ processor + events   │   │  │
│  │  │ cluster     │  │ (catalog, orders)│  │                      │   │  │
│  │  │             │  └─────────────────┘  └──────────────────────┘   │  │
│  │  │ ┌─────────┐ │                                                    │  │
│  │  │ │ retail- │ │  ALB (Application Load Balancer)                    │  │
│  │  │ │ app ns  │◄├────────────────────────────────────────────────────┤  │
│  │  │ │         │ │  Internet-facing, HTTP:80                           │  │
│  │  │ └─────────┘ │                                                    │  │
│  │  └──────────────────────────────────────────────────────────────────┘  │
│  └─────────────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────┘
```

- **Data storage:** RDS (MySQL for catalog, PostgreSQL for orders) — external, persistent. DynamoDB for cart — AWS service. No in-memory-only storage.
- **Load balancer:** AWS Application Load Balancer (ALB) via `aws-load-balancer-controller` + Ingress.
- **Event-driven:** S3 → Lambda (s3:ObjectCreated) for asset processing.

---

## 3. Components

| Component | Description |
|-----------|-------------|
| **EKS Cluster** | `barakat-2025-capstone-bedrock-cluster` — Kubernetes 1.29+ |
| **Application Namespace** | `retail-app` — Retail Store Sample App |
| **RDS** | MySQL (catalog), PostgreSQL (orders) — used by all app services |
| **ALB** | Application Load Balancer — Ingress for retail-store-ui |
| **Lambda** | `barakat-2025-capstone-bedrock-asset-processor` — S3-triggered, CloudWatch logging |
| **S3** | `barakat-2025-capstone-bedrock-assets-0347` — Event notification to Lambda |
| **IAM User** | `barakat-2025-capstone-bedrock-dev-view` — EKS read + S3 upload |

---

## 4. Quick Start

### Prerequisites

- Terraform >= 1.5.0  
- AWS CLI (`aws configure`)  
- kubectl  
- Python 3 (for Lambda packaging)

### Deploy

```bash
# 1. Package Lambda (required before Terraform)
python3 scripts/package_lambda_handler.py

# 2. Full deployment (~25–35 min)
bash scripts/deploy_full_stack.sh
# or: make deploy-full

# 3. Configure kubeconfig
aws eks update-kubeconfig --region us-east-1 --name barakat-2025-capstone-bedrock-cluster

# 4. Get application URL
kubectl get ingress -n retail-app
```

---

## 5. Application URL

After deployment:

```bash
kubectl get ingress -n retail-app
```

Use the **ADDRESS** column (e.g. `k8s-retail-xxxx.elb.amazonaws.com`). Open `http://<ADDRESS>` in a browser.

The ALB is internet-facing and routes traffic to `retail-store-ui` (port 80) in the cluster.

---

## 6. EKS Cluster Access

### kubectl

```bash
aws eks update-kubeconfig --region us-east-1 --name barakat-2025-capstone-bedrock-cluster
kubectl get pods -n retail-app
```

### Developer IAM User (barakat-2025-capstone-bedrock-dev-view)

```bash
# Get credentials from Terraform output
terraform -chdir=infra/envs/dev output bedrock_dev_view_access_key_id
terraform -chdir=infra/envs/dev output bedrock_dev_view_secret_access_key

# Configure and verify
aws configure --profile barakat-2025-capstone-bedrock-dev-view  # Use the keys above
aws eks describe-cluster --name barakat-2025-capstone-bedrock-cluster --region us-east-1 --profile barakat-2025-capstone-bedrock-dev-view
```

---

## 7. Logging & Observability

### Application Logs (in cluster)

- **CloudWatch Observability addon** — collects container logs from `retail-app` namespace.
- **Log groups:**
  - `/aws/eks/barakat-2025-capstone-bedrock-cluster/cluster` — Control plane
  - `/aws/containerinsights/barakat-2025-capstone-bedrock-cluster/application` — Application workloads

### Lambda Logs

- Log group: `/aws/lambda/barakat-2025-capstone-bedrock-asset-processor`
- Retention: 14 days

### Viewing Logs

```bash
# EKS control plane
aws logs tail /aws/eks/barakat-2025-capstone-bedrock-cluster/cluster --region us-east-1 --follow

# Lambda
aws logs tail /aws/lambda/barakat-2025-capstone-bedrock-asset-processor --region us-east-1

# Verification script
bash scripts/verify_logs.sh
```

### CloudWatch Console

- **Logs:** CloudWatch → Log groups → filter by `/aws/eks/barakat-2025-capstone-bedrock-cluster`
- **Metrics:** Container Insights → select `barakat-2025-capstone-bedrock-cluster`

---

## 8. CI/CD Pipeline

| Workflow | Trigger | Action |
|----------|---------|--------|
| `terraform-plan.yml` | Pull request | Plan, validate, TFLint |
| `terraform-apply.yml` | Push to main | Apply dev |
| `terraform-dev.yml` | Manual | Plan/apply dev |

**Required:** GitHub secret `AWS_ROLE_ARN` (OIDC role for GitHub Actions).

See [.github/workflows/README.md](.github/workflows/README.md) for setup.

---

## 9. Troubleshooting

| Issue | Fix |
|-------|-----|
| Lambda zip not found | `python3 scripts/package_lambda_handler.py` |
| EKS version unsupported | Set `cluster_version = "1.29"` in terraform.tfvars |
| IAM user already exists | Set `use_existing_bedrock_dev_view_user = true` in terraform.tfvars |
| No ingress ADDRESS | Wait 2–5 min after pods ready; ALB creation takes time |
| App logs not visible | Ensure CloudWatch Observability addon is installed |

---

## 10. Contributing

1. Create a feature branch  
2. Run `make fmt-check` and `make validate`  
3. Push and open a pull request  
4. CI runs plan/validation; merge to main to apply  

---

## Repository Structure

```
Capstone-Project-Bedrock/
├── .github/workflows/     # CI/CD
├── docs/                  # Deployment guide, logs, success criteria
├── infra/
│   ├── envs/dev|staging|prod/
│   └── modules/          # VPC, EKS, persistence, serverless, app, alb_controller, observability
├── lambda/hello/          # barakat-2025-capstone-bedrock-asset-processor source
├── scripts/               # deploy_full_stack, test_lambda, verify_*
└── Makefile
```

## License

Project Bedrock (Capstone Project)
