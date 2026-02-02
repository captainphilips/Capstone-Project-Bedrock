# Project Bedrock

A comprehensive Terraform-based infrastructure-as-code solution for deploying a retail application on AWS EKS with supporting services.

## Structure

- **`infra/`** - Terraform infrastructure code
  - **`modules/`** - Reusable Terraform modules (VPC, EKS, IAM, app, observability, serverless, RDS)
  - **`envs/`** - Per-environment configurations (dev, staging, prod)
- **`services/lambda/`** - Lambda function source code and build artifacts
- **`policies/`** - IAM and RBAC policy definitions
- **`scripts/`** - Helper scripts for deployment and management
- **`.github/workflows/`** - CI/CD automation

## Quick Start

### Prerequisites

- Terraform >= 1.5.0
- AWS CLI configured with appropriate credentials
- `make` for running common commands

### Deploy Dev Environment

```bash
# Plan infrastructure
make plan-dev

# Apply infrastructure
make apply-dev

# View outputs
make output-dev
```

## Modules

- **VPC** - Virtual Private Cloud with public/private subnets, NAT gateways, and routing
- **EKS** - Elastic Kubernetes Service cluster with node groups and OIDC provider
- **IAM** - Developer users and AWS auth mappings
- **RBAC** - Kubernetes role-based access control
- **Observability** - CloudWatch logging and monitoring
- **App** - Retail application deployment (Kubernetes + Helm)
- **Serverless** - S3 bucket and Lambda function processor
- **RDS** - (Optional) MySQL and PostgreSQL databases

## State Management

Remote state is stored in S3 with DynamoDB locking:
- Bucket: `project-bedrock-0347-tf-state`
- Lock table: `project-bedrock-tf-lock`

## Contributing

1. Create a feature branch
2. Make changes and test locally
3. Run `make fmt-check` and `make validate`
4. Push and create a pull request
5. CI/CD will run plan and validation
6. After approval, merge to main for apply

## License

Project Bedrock (Capstone Project)
