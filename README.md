# URL Shortener — Production-Ready AWS ECS Deployment

> **The Next Generation of the CoderCo ECS Project**  
> A production-ready URL shortener service deployed on AWS ECS Fargate with blue/green deployments, VPC-only connectivity, WAF protection, and a CI/CD pipeline powered by GitHub OIDC.

## Overview

This project implements a production-grade URL shortener service on AWS. The service accepts long URLs and returns short, unique codes that redirect to the original URLs.

**Service Behavior:**

- `POST /shorten` with `{"url": "https://example.com/my/very/long/path"}`
  → Returns `{"short": "abc123ef", "url": "https://example.com/my/very/long/path"}`
- `GET /abc123ef`
  → HTTP 302 redirect to `https://example.com/my/very/long/path`
- `GET /healthz`
  → Returns `{"status": "ok"}` (used for health checks)

## Application Status

The application is live and accessible via HTTPS. FastAPI automatically generates interactive API documentation using Swagger UI:

**Live Application:**

- **Swagger UI:** `https://<your-domain>/docs`
- **ReDoc:** `https://<your-domain>/redoc`
- **OpenAPI JSON:** `https://<your-domain>/openapi.json`

### Interactive API Documentation

The Swagger UI provides interactive documentation for all endpoints:

- **GET `/healthz`** — Health check endpoint (returns `{"status": "ok"}`)
- **POST `/shorten`** — Create a short URL from a long URL
  - Request body: `{"url": "https://example.com/very/long/url"}`
  - Response: `{"short": "abc123ef", "url": "https://example.com/very/long/url"}`
- **GET `/{short_id}`** — Resolve short ID to original URL (returns HTTP 302 redirect)

The API documentation includes:

- **FastAPI** version 0.1.0
- **OpenAPI Specification** 3.1
- Request/response schemas (`ShortenPayload`, `ValidationError`, etc.)
- Interactive testing capability directly from the browser

## Architecture Highlights

![Architecture](images/architecture-diagram.png)

### Core Infrastructure

- **ECS Fargate** service running FastAPI in containers
- **Application Load Balancer (ALB)** with HTTPS termination
- **AWS WAF** protecting the ALB with managed rule sets
- **DynamoDB** for URL mappings (PAY_PER_REQUEST with PITR enabled)
- **Private subnets only** — no public IPs on tasks
- **VPC Endpoints** for ECR, S3, DynamoDB, and CloudWatch Logs (no NAT gateways)
- **Blue/Green deployments** via AWS CodeDeploy with automatic rollback
- **GitHub Actions CI/CD** using OIDC (no long-lived credentials)

### Security & Compliance

- Least-privilege IAM roles for ECS tasks (DynamoDB `GetItem`/`PutItem` only)
- KMS CMK encryption for DynamoDB at rest
- Security groups restricting ingress to ALB only
- WAF rules: Common Rule Set, IP Reputation, Known Bad Inputs, and more

## Repository Structure

```
url-shortener-app/
├── app/                    # Python FastAPI application
│   ├── src/               # Application source code
│   ├── tests/             # Unit tests
│   ├── Dockerfile         # Container image definition
│   └── requirements.txt   # Python dependencies
├── terraform/             # Infrastructure as Code
│   ├── modules/           # Reusable Terraform modules
│   │   ├── networking/    # VPC, subnets, routing (VPC endpoints)
│   │   ├── ecs/           # ECS cluster, task definitions, service
│   │   ├── alb/           # Application Load Balancer
│   │   ├── waf/           # AWS WAF web ACL
│   │   ├── dynamodb/      # DynamoDB table
│   │   ├── codedeploy/    # CodeDeploy app & deployment group
│   │   ├── endpoints/     # VPC endpoints configuration
│   │   ├── route53/       # DNS configuration (optional)
│   │   └── autoscaling/   # ECS service autoscaling
│   ├── environments/      # Environment-specific configurations
│   │   ├── dev/
│   │   ├── staging/
│   │   └── prod/
│   ├── 0-provider.tf      # AWS provider configuration
│   ├── 1-backend.tf       # S3 backend + DynamoDB locking
│   ├── 2-main.tf          # Module wiring
│   ├── 3-variables.tf     # Variable definitions
│   └── 4-outputs.tf       # Output values
├── .github/workflows/     # GitHub Actions CI/CD
│   ├── ci.yaml           # Build, test, scan, push to ECR
│   ├── tfplan.yaml        # Terraform plan with security scans
│   ├── tfapply.yaml       # Terraform apply
│   └── tfdestroy.yaml     # Infrastructure teardown
└── README.md             # This file
```

## Getting Started

### Prerequisites

- AWS Account with appropriate permissions
- Terraform >= 1.12.2
- Docker (for local testing)
- GitHub repository with Actions enabled

### Initial Setup

1. **Configure Terraform Backend**

   The Terraform state is stored in S3 with State locking. Configure the backend in `terraform/1-backend.tf`:

   ```bash
   cd terraform
   terraform init
   ```

2. **Set Up GitHub OIDC**

   Create an IAM role in AWS that trusts GitHub's OIDC provider:

   ```json
   {
     "Version": "2012-10-17",
     "Statement": [
       {
         "Effect": "Allow",
         "Principal": {
           "Federated": "arn:aws:iam::<account-id>:oidc-provider/token.actions.githubusercontent.com"
         },
         "Action": "sts:AssumeRoleWithWebIdentity",
         "Condition": {
           "StringEquals": {
             "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
           },
           "StringLike": {
             "token.actions.githubusercontent.com:sub": "repo:<your-github-org>/<your-repo>:*"
           }
         }
       }
     ]
   }
   ```

   Add the role ARN as a GitHub secret: `AWS_IAM_ROLE_ARN`

3. **Configure Environment Variables**

   Update `terraform/environments/dev/dev.terraform.tfvars` with your configuration values.

### Local Development & Testing

You can test the application locally before deploying:

```bash
cd app
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
uvicorn src.main:app --reload
```

Run tests:

```bash
pytest tests/
```

**Tip:** Use [LocalStack](https://localstack.cloud/) to test Terraform configurations and CI/CD flows locally without incurring AWS costs:

```bash
# Install LocalStack
pip install localstack

# Start LocalStack services
localstack start -d

# Configure AWS CLI to use LocalStack
export AWS_ENDPOINT_URL=http://localhost:4566
```

## CI/CD Pipeline

### GitHub Actions Workflows

#### 1. CI Workflow (`.github/workflows/ci.yaml`)

- **Triggers:** Manual (`workflow_dispatch`)
- **Jobs:**
  - Build Docker image for ARM64 architecture
  - Scan image with Trivy vulnerability scanner
  - Push image to Amazon ECR

#### 2. Terraform Plan (`.github/workflows/tfplan.yaml`)

- **Triggers:** Manual (`workflow_dispatch`)
- **Jobs:**
  - Run Checkov security scanning
  - Run TFLint for Terraform best practices
  - Initialise Terraform backend
  - Validate and format Terraform code
  - Select/create workspace (dev/staging/prod)
  - Generate Terraform plan

#### 3. Terraform Apply (`.github/workflows/tfapply.yaml`)

- **Triggers:** Manual (`workflow_dispatch`)
- **Jobs:**
  - Initialise Terraform
  - Select workspace
  - Apply Terraform changes

#### 4. Terraform Destroy (`.github/workflows/tfdestroy.yaml`)

- **Triggers:** Manual (`workflow_dispatch`)
- **Jobs:**
  - Destroy all infrastructure resources
  - ⚠️ **Use with caution**

### AWS Authentication

All workflows use **GitHub OIDC** to assume an AWS IAM role. No long-lived credentials are stored in GitHub Secrets. The workflows require:

- `permissions.id-token: write` in the workflow file
- `AWS_IAM_ROLE_ARN` secret containing the IAM role ARN
- IAM role trust policy allowing GitHub Actions to assume the role

## Deployment

### Manual Deployment

```bash
cd terraform

# Initialise and select workspace
terraform init
terraform workspace select dev || terraform workspace new dev

# Plan
terraform plan -var-file=environments/dev/dev.terraform.tfvars

# Apply
terraform apply -var-file=environments/dev/dev.terraform.tfvars
```

### Deployment via GitHub Actions

1. Push code to trigger CI workflow (or run manually)
2. Run "Terraform Plan" workflow and review the plan
3. Run "Terraform Apply" workflow to deploy

### Blue/Green Deployments

CodeDeploy manages blue/green deployments with:

- **Two target groups** (blue and green) for zero-downtime deployments
- **Automatic rollback** on failed health checks
- **Canary deployment** option (currently configured as `ECSAllAtOnce`, can be changed to `ECSCanary10Percent5Minutes`)
- **Health check path:** `/healthz`

## Infrastructure Details

### VPC Architecture

- **Public subnets:** ALB only
- **Private subnets:** ECS tasks (no public IPs)
- **VPC Endpoints:**
  - ECR (API + DKR) — Interface endpoints for pulling images
  - S3 — Gateway endpoint for state and artifacts
  - DynamoDB — Gateway endpoint for table access
  - CloudWatch Logs — Interface endpoint (if configured)
- **No NAT Gateways:** All AWS service access via VPC endpoints

### Application Configuration

- **Container port:** 8080
- **Environment variable:** `TABLE_NAME` (DynamoDB table name)
- **Health check:** `GET /healthz` returns `{"status": "ok"}`
- **ECS Task Role:** Limited to DynamoDB `GetItem` and `PutItem`
- **ECS Execution Role:** ECR pull and CloudWatch Logs write permissions

### DynamoDB

- **Billing mode:** PAY_PER_REQUEST
- **Encryption:** KMS CMK
- **Point-in-time recovery (PITR):** Enabled
- **Table structure:**
  - Partition key: `short_id` (string)
  - Attributes: `url` (string)

### AWS WAF

WAF is attached to the ALB with the following managed rule sets:

- AWS Managed Rules Common Rule Set
- AWS Managed Rules Linux Rule Set
- AWS Managed Rules Amazon IP Reputation List
- AWS Managed Rules Anonymous IP List
- AWS Managed Rules Known Bad Inputs Rule Set
- AWS Managed Rules Unix Rule Set
- AWS Managed Rules Windows Rule Set

## Deliverables Checklist

### ✅ Service Endpoints

- [x] `GET /healthz` → `{"status": "ok"}`
- [x] `POST /shorten` → Returns `{"short": "...", "url": "..."}`
- [x] `GET /{short}` → HTTP 302 redirect

### ✅ CI/CD Pipeline

- [x] CI: Build, test, scan (Trivy), push to ECR on main
- [x] CD: Terraform plan (PR) and apply (main) using OIDC
- [x] CodeDeploy canary/blue-green deployment triggered

### ✅ Evidence Required

- [ ] Screenshot of OIDC role trust policy
- [ ] CodeDeploy deployment screen showing canary + rollback test
- [ ] WAF associated to ALB
- [ ] VPC Endpoints list (S3/DDB/ECR/logs/etc.)
- [ ] No NAT gateways on the bill

## Decisions & Trade-offs

### Architecture Decisions

- **ECS Fargate over Lambda:** Better suited for containerised apps with persistent connections and predictable performance
- **Private subnets only:** Enhanced security by eliminating public IP exposure
- **VPC Endpoints over NAT Gateways:** Cost savings (~$32/month per NAT gateway) while maintaining connectivity
- **PAY_PER_REQUEST DynamoDB:** Suitable for variable/unpredictable traffic; scales automatically
- **Blue/Green via CodeDeploy:** Zero-downtime deployments with automatic rollback capability

### Security Trade-offs

- **WAF managed rules:** Balances security and flexibility; some rules may need tuning for specific use cases
- **Least-privilege IAM:** Task role limited to DynamoDB operations only; execution role for ECR and logs
- **KMS CMK encryption:** Adds cost but provides full key management control

### Cost Considerations

- **No NAT Gateways:** Significant cost savings (~$32/month + data transfer per AZ)
- **VPC Endpoints:** Interface endpoints incur hourly charges (~$7/month + data processing)
- **ALB + WAF:** Fixed hourly costs + per-GB/request charges
- **DynamoDB PAY_PER_REQUEST:** Pay only for actual usage, but storage costs apply

### Teardown Instructions

**Immediately after completing your deployment and taking screenshots:**

```bash
cd terraform
terraform workspace select dev
terraform destroy -var-file=environments/dev/dev.terraform.tfvars -auto-approve
```

Or use the GitHub Actions destroy workflow (use with caution).

**Note:** Even with no traffic, ALB, WAF, and VPC endpoints continue to incur charges until deleted.

## Operations & Troubleshooting

### Health Checks

- Health check endpoint: `GET /healthz`
- Target group health checks: Configured to use `/healthz` path
- Health check interval: 30 seconds (default)

### Logs

- **ECS Task Logs:** CloudWatch Logs group `/ecs/<env>-<service-name>`
- **ALB Access Logs:** Can be enabled for request logging
- **WAF Logs:** CloudWatch Logs group `aws-waf-log-group` (if enabled)

### Common Issues

#### ECS Tasks Not Starting

- Check CloudWatch Logs for container errors
- Verify task execution role has ECR pull permissions
- Confirm security groups allow traffic from ALB
- Verify VPC endpoints are configured correctly

#### DynamoDB Access Denied

- Verify ECS task role includes `dynamodb:GetItem` and `dynamodb:PutItem`
- Check table name matches `TABLE_NAME` environment variable
- Confirm VPC endpoint routing for DynamoDB

#### CodeDeploy Deployment Fails

- Check CodeDeploy deployment status in AWS Console
- Review CloudWatch metrics for health check failures
- Verify both blue and green target groups are configured
- Check ECS service events for task placement failures

### Rollback

**Application Rollback:**

- Revert to previous container image tag in ECS task definition
- Re-run Terraform apply or trigger CodeDeploy deployment

**Infrastructure Rollback:**

- Revert Terraform commit
- Run `terraform plan` and `terraform apply` with previous configuration

## Monitoring

- **CloudWatch Logs:** ECS task logs, ALB access logs (optional), WAF logs
- **CloudWatch Metrics:** ECS service metrics, ALB request/response metrics, WAF metrics
- **Container Insights:** Recommended for detailed ECS performance metrics

## Application Screenshot

![FastAPI Swagger UI](images/fastapi-swagger-ui.png)

The FastAPI interactive API documentation showcasing the live URL shortener service endpoints.
