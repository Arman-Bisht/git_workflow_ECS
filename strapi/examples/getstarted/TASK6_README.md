# Task 6: Automate Strapi Deployment with GitHub Actions + Terraform

## Overview
This task implements CI/CD pipelines using GitHub Actions to automate Docker image builds and Terraform deployments.

## CI/CD Pipeline Proof

**CI Workflow - Automated Docker Build & Push to ECR:**
![CI Build Success](../../../../CI_Build.png)

**CD Workflow - Terraform Infrastructure Deployment:**
![CD Deployment Success](../../../../CD_deployment.png)

## Architecture

### 1. CI Pipeline (`.github/workflows/ci.yml`)
**Trigger:** Push to `main` or `Arman_Bisht_v2` branch

**Steps:**
1. Checkout code
2. Configure AWS credentials
3. Login to Amazon ECR
4. Build Docker image from `Dockerfile.ci`
5. Tag image with `latest` and commit SHA
6. Push both tags to ECR

**Outputs:**
- `image_tag`: Git commit SHA
- `image_uri`: Full ECR image URI

### 2. CD Pipeline (`.github/workflows/terraform.yml`)
**Trigger:** Manual workflow dispatch

**Actions Available:**
- `plan`: Preview infrastructure changes
- `apply`: Deploy infrastructure to AWS
- `destroy`: Tear down infrastructure

**Steps:**
1. Checkout code
2. Configure AWS credentials
3. Setup Terraform
4. Run Terraform commands (init, validate, plan/apply/destroy)
5. Output deployment details

## Setup Instructions

### 1. Configure GitHub Secrets

Go to your repository → Settings → Secrets and variables → Actions

Add these secrets:
- `AWS_ACCESS_KEY_ID`: Your AWS access key
- `AWS_SECRET_ACCESS_KEY`: Your AWS secret key

### 2. Verify ECR Repository

Ensure your ECR repository exists:
```bash
aws ecr describe-repositories --repository-names strapi-app --region ap-south-1
```

If not, create it:
```bash
aws ecr create-repository --repository-name strapi-app --region ap-south-1
```

### 3. Set ECR Public Access (if needed)

```bash
aws ecr set-repository-policy \
  --repository-name strapi-app \
  --policy-text file://terraform/ecr-policy.json \
  --region ap-south-1
```

## Usage

### Automatic Deployment (CI)

1. Make changes to your Strapi application
2. Commit and push to `main` or `Arman_Bisht_v2` branch
3. GitHub Actions automatically builds and pushes Docker image to ECR

### Manual Deployment (CD)

1. Go to GitHub → Actions → "CD - Terraform Deployment"
2. Click "Run workflow"
3. Select action:
   - **plan**: Preview changes
   - **apply**: Deploy to AWS
   - **destroy**: Remove infrastructure
4. Click "Run workflow"

### Verify Deployment

After successful deployment:
1. Check GitHub Actions summary for instance details
2. Access Strapi at: `http://<PUBLIC_IP>:1337/admin`
3. Connect via EC2 Instance Connect in AWS Console

## Files Created

```
Script-Smiths/
├── .github/
│   └── workflows/
│       ├── ci.yml              # CI pipeline for Docker builds
│       └── terraform.yml       # CD pipeline for Terraform
└── strapi/examples/getstarted/
    ├── Dockerfile.ci           # Simplified Dockerfile for CI
    └── terraform/
        ├── main.tf             # Terraform configuration
        ├── variables.tf        # Terraform variables
        ├── outputs.tf          # Terraform outputs
        ├── user_data.sh        # EC2 initialization script
        └── ecr-policy.json     # ECR public access policy
```

## Workflow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                     Developer Workflow                       │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
                    ┌──────────────────┐
                    │  Push to GitHub  │
                    └──────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      CI Pipeline (Automatic)                 │
├─────────────────────────────────────────────────────────────┤
│  1. Checkout code                                            │
│  2. Configure AWS credentials                                │
│  3. Login to ECR                                             │
│  4. Build Docker image                                       │
│  5. Push to ECR (latest + commit SHA)                        │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
                    ┌──────────────────┐
                    │  Image in ECR    │
                    └──────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                   CD Pipeline (Manual Trigger)               │
├─────────────────────────────────────────────────────────────┤
│  1. Checkout code                                            │
│  2. Configure AWS credentials                                │
│  3. Setup Terraform                                          │
│  4. Terraform init/validate                                  │
│  5. Terraform plan/apply/destroy                             │
│  6. Output deployment details                                │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
                    ┌──────────────────┐
                    │  EC2 Instance    │
                    │  Running Strapi  │
                    └──────────────────┘
```

## Troubleshooting

### CI Pipeline Fails

**Issue:** Docker build fails
- Check Dockerfile.ci syntax
- Verify base image is accessible

**Issue:** ECR push fails
- Verify AWS credentials in GitHub Secrets
- Check ECR repository exists
- Verify IAM permissions for ECR

### CD Pipeline Fails

**Issue:** Terraform init fails
- Check AWS credentials
- Verify Terraform state location

**Issue:** Terraform apply fails
- Check IAM permissions
- Verify security group rules
- Check instance type availability in region

**Issue:** Instance not accessible
- Wait 5-10 minutes for user_data script to complete
- Check security group allows port 1337
- Verify instance is running in AWS Console

## Cost Considerations

- **EC2 t3.micro**: Free Tier eligible (750 hours/month)
- **EBS 30GB gp3**: ~$2.40/month
- **ECR Storage**: $0.10/GB/month
- **Data Transfer**: First 100GB free

**Estimated Monthly Cost:** ~$2-5 (after Free Tier)

## Security Best Practices

1. ✅ Use GitHub Secrets for AWS credentials
2. ✅ Use IAM user with minimal permissions
3. ✅ ECR repository with public read-only access
4. ✅ Security group restricts access to necessary ports
5. ⚠️ Change default database passwords in production
6. ⚠️ Use HTTPS with SSL certificate for production

## Next Steps

1. Add custom domain with Route 53
2. Set up SSL certificate with ACM
3. Configure CloudWatch monitoring
4. Add automated backups for PostgreSQL
5. Implement blue-green deployment strategy
