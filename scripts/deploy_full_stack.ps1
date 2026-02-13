# Project Bedrock - Full Stack Deployment Script
# Run this script after configuring AWS credentials: aws configure

$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
Set-Location $RepoRoot

Write-Host "`n=== Project Bedrock Full Stack Deployment ===" -ForegroundColor Cyan
Write-Host ""

# 1. Check AWS credentials
Write-Host "[1/6] Checking AWS credentials..." -ForegroundColor Yellow
try {
    $identity = aws sts get-caller-identity 2>&1 | ConvertFrom-Json
    Write-Host "  AWS Account: $($identity.Account)" -ForegroundColor Green
} catch {
    Write-Host "  ERROR: AWS credentials not configured. Run: aws configure" -ForegroundColor Red
    exit 1
}

# 2. Bootstrap S3 + DynamoDB
Write-Host "`n[2/6] Bootstrap Terraform state backend..." -ForegroundColor Yellow
$bucket = "project-bedrock-0347-tf-state"
$table = "project-bedrock-tf-lock"
$region = "us-east-1"

try {
    aws s3api head-bucket --bucket $bucket --region $region 2>$null
    Write-Host "  S3 bucket '$bucket' exists" -ForegroundColor Green
} catch {
    Write-Host "  Creating S3 bucket..." -ForegroundColor Gray
    aws s3api create-bucket --bucket $bucket --region $region
    aws s3api put-bucket-versioning --bucket $bucket --versioning-configuration Status=Enabled
    Write-Host "  S3 bucket created" -ForegroundColor Green
}

try {
    aws dynamodb describe-table --table-name $table --region $region 2>$null
    Write-Host "  DynamoDB table '$table' exists" -ForegroundColor Green
} catch {
    Write-Host "  Creating DynamoDB table..." -ForegroundColor Gray
    aws dynamodb create-table --table-name $table `
        --attribute-definitions AttributeName=LockID,AttributeType=S `
        --key-schema AttributeName=LockID,KeyType=HASH `
        --billing-mode PAY_PER_REQUEST `
        --region $region
    Write-Host "  DynamoDB table created (waiting for active)..." -ForegroundColor Gray
    Start-Sleep -Seconds 5
    Write-Host "  DynamoDB table ready" -ForegroundColor Green
}

# 3. Package Lambda (Python script - cross-platform, no zip utility needed)
Write-Host "`n[3/6] Packaging Lambda function..." -ForegroundColor Yellow
$pyScript = Join-Path $RepoRoot "scripts\package_lambda_handler.py"
if (Get-Command python -ErrorAction SilentlyContinue) {
    python $pyScript
} elseif (Get-Command python3 -ErrorAction SilentlyContinue) {
    python3 $pyScript
} else {
    Write-Host "  ERROR: Python is required. Install Python and try again." -ForegroundColor Red
    exit 1
}
Write-Host "  Lambda package: lambda/hello/build/handler.zip" -ForegroundColor Green

# 4. Terraform Init
Write-Host "`n[4/6] Terraform init..." -ForegroundColor Yellow
Set-Location (Join-Path $RepoRoot "infra\envs\dev")
terraform init -input=false
Write-Host "  Terraform initialized" -ForegroundColor Green

# 5. Terraform Plan
Write-Host "`n[5/6] Terraform plan..." -ForegroundColor Yellow
terraform plan -out=tfplan -input=false

# 6. Terraform Apply
Write-Host "`n[6/6] Terraform apply (this takes 20-30 minutes)..." -ForegroundColor Yellow
terraform apply -input=false tfplan

Write-Host "`n=== Deployment Complete ===" -ForegroundColor Green
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. aws eks update-kubeconfig --region us-east-1 --name barakat-2025-capstone-bedrock-cluster"
Write-Host "  2. kubectl get ingress -n retail-app  (get the Retail Store URL)"
Write-Host "  3. terraform output  (get grading credentials)"
Write-Host ""
