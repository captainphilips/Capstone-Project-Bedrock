# Project Bedrock

A Production-Grade Microservices Platform on AWS EKS

## 1. Introduction & Company Background

InnovateMart is a rapidly growing e-commerce startup focused on redefining the online retail experience. After a successful Series A funding round, the company is expanding its platform to support global customers, increased transaction volumes, and accelerated feature delivery.

To meet these demands, the engineering team has transformed a legacy monolithic application into a cloud-native microservices architecture. This approach enables independent service deployment, horizontal scalability, improved fault isolation, and faster development cycles.

As InnovateMart moves to production, the next step is to establish a robust, secure, and scalable Kubernetes foundation to support mission-critical workloads.

## 2. Project Context: From Monolith to Microservices

The new Retail Store Application consists of loosely coupled services, such as product catalog, cart, checkout, and order management. These services communicate through APIs and asynchronous events, making container orchestration and service discovery essential.

To ensure production readiness, the platform must:

- Run on managed, highly available infrastructure
- Enforce strong security boundaries and access controls
- Provide observability across services and infrastructure
- Support automation and repeatable deployments

Amazon Elastic Kubernetes Service (EKS) was selected as the core orchestration platform for its scalability, security integrations, and strong alignment with AWS-native services.

## 3. Your Mission: Project Bedrock

As the Cloud DevOps Engineer, you are responsible for delivering Project Bedrock, the foundational Kubernetes platform that will support InnovateMart’s production workloads.

Your mission is to design, provision, and operationalize a production-grade Amazon EKS environment that hosts the AWS Retail Store Sample Application and meets enterprise standards.

Key Objectives

You are expected to:

- Provision a secure Amazon EKS cluster
  - Multi-AZ, production-ready architecture
  - Proper IAM integration and network isolation
  - Secure node groups and cluster access controls
- Automate infrastructure delivery
  - Infrastructure as Code (IaC) using tools such as Terraform or AWS CDK
  - Repeatable, version-controlled deployments
  - Environment consistency across stages
- Deploy the Retail Store Application
  - Containerized microservices deployed to EKS
  - Kubernetes best practices (namespaces, services, ingress)
  - Scalable and resilient service configuration
- Implement observability
  - Centralized logging for cluster and application workloads
  - Metrics and basic monitoring for operational visibility
  - Readiness for future alerting and SRE practices
- Extend the platform with event-driven components
  - Integration with AWS serverless services (e.g., Lambda, EventBridge, SQS/SNS)
  - Support for asynchronous workflows and decoupled services
- Prepare the platform for developer hand-off
  - Secure developer access to the cluster
  - Clear separation of duties between platform and application teams
  - A stable foundation for future feature development

## 4. Definition of Success

Project Bedrock is considered successful when:

- Infrastructure provisioning is fully automated and reproducible
- The Retail Store Application is running reliably on Amazon EKS
- Logs and metrics are centralized and accessible
- The cluster is secured, documented, and ready for developer onboarding
- The architecture supports scalability, resilience, and future growth

This platform will serve as the backbone of InnovateMart’s cloud strategy, setting standards for security, reliability, and operational excellence as the company grows globally.

## Repository Structure

- **`infra/`** - Terraform infrastructure code
  - **`modules/`** - Reusable Terraform modules (VPC, EKS, RBAC, observability, serverless)
  - **`envs/`** - Per-environment roots (dev, staging, prod)
- **`lambda/hello/`** - Lambda function source code and build artifacts
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
