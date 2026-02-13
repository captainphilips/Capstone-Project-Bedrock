# Security Controls

## Network Security

| Control | Implementation |
|---------|----------------|
| **Private subnets** | EKS nodes run in private subnets |
| **NAT Gateway** | Outbound-only internet for private subnets |
| **RDS** | In VPC, not publicly accessible |
| **Security groups** | DB access restricted to VPC CIDR |

## Identity & Access

| Control | Implementation |
|---------|----------------|
| **IRSA** | IAM Roles for Service Accounts (ALB controller, External Secrets, CloudWatch) |
| **EKS Access** | IAM user `barakat-2025-capstone-bedrock-dev-view` with View policy |
| **Least privilege** | Developer has read + S3 PutObject on assets bucket only |

## Data Protection

| Control | Implementation |
|---------|----------------|
| **RDS encryption** | Storage encrypted at rest |
| **Secrets** | AWS Secrets Manager for DB credentials |
| **External Secrets** | Synced to Kubernetes, not in manifests |

## Compliance

| Tag | Value |
|-----|-------|
| `Project` | barakat-2025-capstone |
| `Environment` | dev / staging / prod |
| `ManagedBy` | Terraform |

## EKS Hardening

- Control plane logs enabled (api, audit, authenticator, controllerManager, scheduler)
- Public endpoint enabled for kubectl; private endpoint for in-cluster traffic
- Node group: t3.medium, 2–3 nodes, multi-AZ
