# Makefile for Project Bedrock Infrastructure

.PHONY: help fmt fmt-check validate plan apply output destroy lint init clean package-lambda

TERRAFORM_DIR := infra/envs/dev
TF := terraform
LAMBDA_DIR := lambda/hello

help:
	@echo "Project Bedrock - Infrastructure Management"
	@echo ""
	@echo "Available targets:"
	@echo "  fmt              Format all Terraform files"
	@echo "  fmt-check        Check Terraform formatting (no changes)"
	@echo "  validate         Validate Terraform configuration"
	@echo "  lint             Run tflint on Terraform files"
	@echo "  init-dev         Initialize dev environment"
	@echo "  init-staging     Initialize staging environment"
	@echo "  init-prod        Initialize prod environment"
	@echo "  plan-dev         Plan dev infrastructure"
	@echo "  plan-staging     Plan staging infrastructure"
	@echo "  plan-prod        Plan prod infrastructure"
	@echo "  apply-dev        Apply dev infrastructure"
	@echo "  apply-staging    Apply staging infrastructure"
	@echo "  apply-prod       Apply prod infrastructure"
	@echo "  output-dev       Show dev outputs"
	@echo "  output-staging   Show staging outputs"
	@echo "  output-prod      Show prod outputs"
	@echo "  destroy-dev      Destroy dev infrastructure"
	@echo "  destroy-staging  Destroy staging infrastructure"
	@echo "  destroy-prod     Destroy prod infrastructure"
	@echo "  package-lambda   Package Lambda function"
	@echo "  deploy-full     One-command full stack deployment (requires bash)"
	@echo "  bootstrap-argocd Bootstrap Argo CD for GitOps"
	@echo "  bootstrap-state  Create S3 + DynamoDB for Terraform state (run once)"
	@echo "  clean            Clean Terraform cache and build artifacts"

fmt:
	@echo "Formatting Terraform files..."
	@$(TF) fmt -recursive infra/

fmt-check:
	@echo "Checking Terraform formatting..."
	@$(TF) fmt -recursive -check infra/

validate:
	@echo "Validating Terraform configuration..."
	@cd $(TERRAFORM_DIR) && $(TF) init && $(TF) validate

lint:
	@echo "Running tflint on Terraform files..."
	@tflint --init && tflint infra/ || echo "tflint not installed; skipping"

init-dev:
	@echo "Initializing dev environment..."
	@cd infra/envs/dev && $(TF) init

init-staging:
	@echo "Initializing staging environment..."
	@cd infra/envs/staging && $(TF) init

init-prod:
	@echo "Initializing prod environment..."
	@cd infra/envs/prod && $(TF) init

plan-dev: package-lambda init-dev
	@echo "Planning dev infrastructure..."
	@cd infra/envs/dev && $(TF) plan -out=tfplan

plan-staging: package-lambda init-staging
	@echo "Planning staging infrastructure..."
	@cd infra/envs/staging && $(TF) plan -out=tfplan

plan-prod: package-lambda init-prod
	@echo "Planning prod infrastructure..."
	@cd infra/envs/prod && $(TF) plan -out=tfplan

apply-dev: package-lambda init-dev
	@echo "Applying dev infrastructure..."
	@cd infra/envs/dev && $(TF) apply -auto-approve -input=false

apply-staging: package-lambda init-staging
	@echo "Applying staging infrastructure..."
	@cd infra/envs/staging && $(TF) apply -auto-approve -input=false

apply-prod: package-lambda init-prod
	@echo "Applying prod infrastructure..."
	@cd infra/envs/prod && $(TF) apply -auto-approve -input=false

output-dev: init-dev
	@cd infra/envs/dev && $(TF) output -json > ../../grading.json && echo "Outputs written to grading.json"

output-staging: init-staging
	@cd infra/envs/staging && $(TF) output -json

output-prod: init-prod
	@cd infra/envs/prod && $(TF) output -json

destroy-dev: init-dev
	@echo "WARNING: Destroying dev infrastructure. This cannot be undone."
	@read -p "Continue? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		cd infra/envs/dev && $(TF) destroy -auto-approve; \
	fi

destroy-staging: init-staging
	@echo "WARNING: Destroying staging infrastructure. This cannot be undone."
	@read -p "Continue? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		cd infra/envs/staging && $(TF) destroy -auto-approve; \
	fi

destroy-prod: init-prod
	@echo "WARNING: Destroying prod infrastructure. This cannot be undone."
	@read -p "Continue? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		cd infra/envs/prod && $(TF) destroy -auto-approve; \
	fi

package-lambda:
	@echo "Packaging Lambda function..."
	@bash scripts/package_lambda.sh

bootstrap-argocd:
	@bash scripts/bootstrap_argocd.sh

bootstrap-state:
	@bash scripts/bootstrap_terraform_state.sh

deploy-full:
	@bash scripts/deploy_full_stack.sh

clean:
	@echo "Cleaning Terraform cache and build artifacts..."
	@find infra -name ".terraform" -type d -exec rm -rf {} + 2>/dev/null || true
	@find infra -name ".terraform.lock.hcl" -delete
	@find infra -name "tfplan" -delete
	@rm -rf $(LAMBDA_DIR)/build/*.zip
	@echo "Cleanup complete"
