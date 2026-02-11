# Developer Onboarding Guide

## Prerequisites

- AWS CLI v2
- kubectl
- Access to `bedrock-dev-view` credentials (from `terraform output`)

---

## 1. Obtain Credentials

```bash
cd infra/envs/dev
terraform output bedrock_dev_view_access_key_id
terraform output bedrock_dev_view_secret_access_key
```

Configure AWS CLI:

```bash
aws configure --profile bedrock-dev
# Access Key ID: [from output]
# Secret Access Key: [from output]
# Region: us-east-1
```

---

## 2. Configure kubectl

```bash
aws eks update-kubeconfig \
  --region us-east-1 \
  --name project-bedrock-cluster \
  --profile bedrock-dev
```

Verify:

```bash
kubectl get nodes --profile bedrock-dev
# Or: export KUBECONFIG or use default profile
```

---

## 3. Access the Retail Store

```bash
# Get the URL
kubectl get ingress -n retail-app

# Open http://<ADDRESS> in browser
```

---

## 4. Permissions Summary

| Action | Allowed |
|--------|---------|
| `eks:DescribeCluster` | Yes |
| `kubectl get` (read) | Yes (EKS View policy) |
| `s3:PutObject` on assets bucket | Yes |
| AWS read-only (most services) | Yes |
| Modify cluster resources | No |

---

## 5. Port-Forward (if Ingress not ready)

```bash
kubectl port-forward svc/retail-store-ui 8080:80 -n retail-app
# Open http://localhost:8080
```
