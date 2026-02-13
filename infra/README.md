# Infrastructure (Terraform)

Infrastructure as Code for Project Bedrock — VPC, EKS, RDS, Lambda, S3, and supporting services.

## Structure

```
infra/
├── envs/                    # Environment-specific root modules
│   ├── dev/                 # Development
│   ├── staging/             # Staging
│   └── prod/                # Production
└── modules/                 # Reusable Terraform modules
    ├── vpc/                 # VPC, subnets, NAT
    ├── eks/                 # EKS cluster, node groups
    ├── persistence/         # RDS MySQL, Postgres, Secrets Manager
    ├── serverless/          # Lambda, S3 assets bucket
    ├── rbac/                # IAM user barakat-2025-capstone-bedrock-dev-view, EKS access
    ├── observability/       # CloudWatch Observability addon
    ├── external_secrets/    # External Secrets Operator
    ├── alb_controller/      # AWS Load Balancer Controller + Ingress
    └── app/                 # Retail Store Sample App (Helm)
```

## Quick Commands

```bash
# From repo root
make plan-dev      # Plan
make apply-dev     # Apply
make output-dev    # Export outputs to grading.json
```

## State Backend

- **S3**: `project-bedrock-0347-tf-state`
- **DynamoDB**: `project-bedrock-tf-lock`
- **Region**: us-east-1
