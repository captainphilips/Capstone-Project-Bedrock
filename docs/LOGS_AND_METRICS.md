# Logs and Metrics — Centralized Observability

## Overview

Project Bedrock centralizes logs and metrics in **AWS CloudWatch**:

- **EKS control plane logs** — api, audit, authenticator, controllerManager, scheduler
- **Container logs** — Application workloads via CloudWatch Observability addon
- **Container Insights** — Infrastructure and application metrics

---

## Accessing Logs

### 1. AWS Console

1. Open [CloudWatch Logs](https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#logsV2:log-groups)
2. Filter by: `/aws/eks/barakat-2025-capstone-bedrock-cluster`
3. Log groups:
   - `/aws/eks/barakat-2025-capstone-bedrock-cluster/cluster` — Control plane
   - `/aws/containerinsights/barakat-2025-capstone-bedrock-cluster/application` — App logs (after addon)

### 2. AWS CLI

```bash
# List log groups
aws logs describe-log-groups \
  --log-group-name-prefix /aws/eks/barakat-2025-capstone-bedrock-cluster \
  --region us-east-1

# Tail recent logs
aws logs tail /aws/eks/barakat-2025-capstone-bedrock-cluster/cluster \
  --region us-east-1 \
  --follow
```

### 3. Verification Script

```bash
bash scripts/verify_logs.sh
```

---

## Accessing Metrics

### 1. Container Insights (Console)

1. Open [CloudWatch → Container Insights](https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#container-insights:infrastructure)
2. Select cluster: `barakat-2025-capstone-bedrock-cluster`
3. View: Performance monitoring, Logs, Metrics

### 2. Application Signals

1. CloudWatch → Application Signals (if enabled by addon)
2. View traces and service maps for retail-app workloads

### 3. Verification Script

```bash
bash scripts/verify_metrics.sh
```

---

## Log Retention

- Default: 7 days (configurable in `infra/modules/observability`)
- Adjust via `log_retention_days` variable
