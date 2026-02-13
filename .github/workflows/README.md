# CI/CD Pipeline

## Workflows

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `terraform-plan.yml` | Pull request (infra/lambda paths) | Plan, validate, TFLint |
| `terraform-apply.yml` | Push to main | Apply dev infrastructure |
| `terraform-dev.yml` | Manual (workflow_dispatch) | Plan/apply dev |
| `terraform-staging.yml` | Manual/push | Staging environment |
| `terraform-prod.yml` | Manual/push | Production environment |

## Required Setup

### GitHub Secrets

Configure these in **Settings → Secrets and variables → Actions**:

| Secret | Description |
|--------|-------------|
| `AWS_ROLE_ARN` | IAM role ARN for OIDC federation (e.g. `arn:aws:iam::123456789012:role/github-actions`) |

### AWS OIDC for GitHub Actions

1. Create an OIDC identity provider in IAM for `token.actions.githubusercontent.com`
2. Create an IAM role with trust policy allowing `sts:AssumeRoleWithWebIdentity`
3. Attach policies for Terraform (S3, DynamoDB, EKS, etc.)
4. Set `AWS_ROLE_ARN` in GitHub secrets

### Pipeline Flow

1. **PR** → `terraform-plan` runs format check, validate, plan for dev/staging/prod
2. **Merge to main** → `terraform-apply` runs apply for dev
3. **Manual** → Run `terraform-dev` with optional apply
