# Definition of Success — Verification Guide

This document maps each success criterion to its implementation and how to verify it.

---

## 1. Infrastructure provisioning is fully automated and reproducible

### Implementation
- **Terraform** in `infra/`
- **GitHub Actions**: `terraform-apply.yml` runs on push to `main` (infra or lambda changes)
- **Deploy script**: `scripts/deploy_full_stack.sh` for one-command local deployment

### Verification
```bash
# From a fresh clone, run:
cd ~/Capstone-Project-Bedrock
bash scripts/deploy_full_stack.sh
# Or: push to main → CI runs terraform apply
```
✅ **Pass** if: `terraform apply` completes without manual steps beyond `aws configure`.

---

## 2. The Retail Store Application is running reliably on Amazon EKS

### Implementation
- **Helm chart**: AWS Retail Store Sample App in `infra/modules/app/`
- **Namespace**: `retail-app`
- **Ingress**: ALB via `retail-store-ui` (in alb_controller module)

### Verification
```bash
aws eks update-kubeconfig --region us-east-1 --name barakat-2025-capstone-bedrock-cluster
kubectl get pods -n retail-app
kubectl get ingress -n retail-app
```
✅ **Pass** if: All pods are `Running` and Ingress has an ADDRESS. Open `http://<ADDRESS>` in browser.

---

## 3. Logs and metrics are centralized and accessible

### Implementation
- **EKS control plane logs**: `api`, `audit`, `authenticator`, `controllerManager`, `scheduler`
- **CloudWatch Observability addon**: `amazon-cloudwatch-observability` in `infra/modules/observability/`
- **See**: [docs/LOGS_AND_METRICS.md](LOGS_AND_METRICS.md)

### Verification
```bash
# Logs in CloudWatch
aws logs describe-log-groups --log-group-name-prefix /aws/eks/barakat-2025-capstone-bedrock-cluster --region us-east-1

# Container Insights / Application Signals (after addon install)
# → AWS Console → CloudWatch → Container Insights
```
✅ **Pass** if: Log groups exist and Container Insights shows cluster metrics.

---

## 4. The cluster is secured, documented, and ready for developer onboarding

### Implementation
- **Security**: Private subnets, IAM IRSA, RBAC. See [docs/SECURITY.md](SECURITY.md)
- **Developer access**: IAM user `barakat-2025-capstone-bedrock-dev-view` with EKS view + S3 PutObject
- **Documentation**: [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md), [DEVELOPER_ONBOARDING.md](DEVELOPER_ONBOARDING.md)

### Verification
```bash
terraform output bedrock_dev_view_access_key_id
terraform output bedrock_dev_view_secret_access_key
# Configure AWS CLI with these → aws eks describe-cluster should work
```
✅ **Pass** if: `barakat-2025-capstone-bedrock-dev-view` can describe cluster and access S3 assets bucket.

---

## 5. The architecture supports scalability, resilience, and future growth

### Implementation
- **EKS node group**: `min_size=2`, `max_size=3`, multi-AZ subnets
- **RDS**: Multi-AZ for staging/prod (`multi_az=true`), encrypted
- **Modular Terraform**: Reusable modules for staging/prod
- **Verify**: `bash scripts/verify_resilience.sh`

### Verification
```bash
kubectl get nodes -o wide
# Expect 2+ nodes across AZs
```
✅ **Pass** if: Nodes run in multiple AZs; scaling can be tested via `kubectl scale`.

---

## Common Blockers

| Blocker | Fix |
|---------|-----|
| **Lambda apply fails** | Ensure `lambda/hello/build/handler.zip` exists (run `python3 scripts/package_lambda_handler.py` or `bash scripts/package_lambda_handler.sh`) |
| **EKS: unsupported Kubernetes version 1.27** | Use 1.29, 1.31, 1.32, 1.33, or 1.34. Set `cluster_version = "1.29"` in terraform.tfvars |
| **IAM: barakat-2025-capstone-bedrock-dev-view already exists** | Set `use_existing_bedrock_dev_view_user = true` in terraform.tfvars |
| **Partial apply (only VPC)** | Run `terraform apply -auto-approve` again; check for errors in EKS, RDS, or serverless |
| **No outputs** | Outputs appear only after full apply. Re-run apply to completion. |
| **Observability addon fails** | Check addon compatibility: `aws eks describe-addon-versions --addon-name amazon-cloudwatch-observability --kubernetes-version 1.29` |
| **S3 event not triggering Lambda** | Verify `aws_s3_bucket_notification` and `aws_lambda_permission` in serverless module; test with `bash scripts/test_lambda.sh` |