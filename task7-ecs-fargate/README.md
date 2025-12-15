# Task 7: Strapi on AWS ECS Fargate with GitHub Actions CI/CD

## Overview
Deploy a Strapi application on AWS ECS Fargate, managed entirely via Terraform. GitHub Actions workflow creates fresh images, applies tagging, pushes to ECR registry, and updates the ECS task revision.

## Architecture

- **ECS Fargate**: Serverless container orchestration
- **ECR**: Docker image registry  
- **Default VPC**: Using existing AWS VPC
- **SQLite**: Embedded database (no RDS needed)
- **Security Groups**: Network access control
- **IAM Roles**: Task execution permissions

## Quick Start

### 1. Infrastructure Setup

```bash
cd task7-ecs-fargate/terraform

# Initialize Terraform
terraform init

# Apply infrastructure
terraform apply
```

### 2. Configure GitHub Secrets

Add to your repository settings → Secrets:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

### 3. Push Changes

Any push to `task7-ecs-fargate/` directory triggers:
1. Docker image build
2. Push to ECR with commit SHA + latest tags
3. ECS task definition update
4. Automatic deployment

## GitHub Actions Workflow

**File**: `.github/workflows/ecs-ci.yml`

**Triggers**: Push to main/Arman_Bisht_v2 branches

**Jobs**:
1. **build-and-push**: Builds Docker image, tags with commit SHA, pushes to ECR
2. **deploy**: Updates ECS task definition and deploys new version

## Accessing the Application

After deployment, get the task public IP:

```bash
aws ecs list-tasks --cluster arman-strapi-ecs-cluster --service-name arman-strapi-ecs-service --region ap-south-1 --query 'taskArns[0]' --output text | xargs -I {} aws ecs describe-tasks --cluster arman-strapi-ecs-cluster --tasks {} --region ap-south-1 --query "tasks[0].attachments[0].details[?name=='networkInterfaceId'].value" --output text | xargs -I {} aws ec2 describe-network-interfaces --network-interface-ids {} --region ap-south-1 --query "NetworkInterfaces[0].Association.PublicIp" --output text
```

Access Strapi at: `http://<PUBLIC_IP>:1337`

## Cost Estimate

- **ECS Fargate**: ~$15/month (0.5 vCPU, 1GB RAM)
- **ECR Storage**: ~$1/month
- **S3 (Terraform state)**: <$1/month
- **Total**: ~$17/month or ~$1.50 for 2-3 days testing

## Cleanup

```bash
cd task7-ecs-fargate/terraform
terraform destroy
```

## Repository

https://github.com/Arman-Bisht/git_workflow_ECS.git
