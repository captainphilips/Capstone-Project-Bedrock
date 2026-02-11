# Scripts

Helper scripts for deployment, verification, and operations.

## Deployment

| Script | Description |
|--------|-------------|
| `deploy_full_stack.sh` | **One-command deploy** (Linux/WSL): bootstrap, Lambda, terraform apply |
| `deploy_full_stack.ps1` | Same for Windows PowerShell |
| `package_lambda_handler.sh` | Package Lambda → `lambda/hello/build/handler.zip` |
| `package_lambda.sh` | Package Lambda with optional requirements.txt |

## Terraform

| Script | Description |
|--------|-------------|
| `tf_init.sh` | Initialize Terraform |
| `tf_plan.sh` | Run terraform plan |
| `tf_apply.sh` | Run terraform apply |
| `apply_and_kubeconfig.sh` | Apply + update kubeconfig |

## GitOps

| Script | Description |
|--------|-------------|
| `bootstrap_argocd.sh` | Install Argo CD, point at GitOps overlays |

## Verification

| Script | Description |
|--------|-------------|
| `verify_deployment.sh` | Check retail-app pods, port-forward to UI |
| `verify_logs.sh` | Verify logging setup |
| `test_dev_access.sh` | Test bedrock-dev-view access |
| `helm_setup.sh` | Manual Helm chart setup (fallback) |
