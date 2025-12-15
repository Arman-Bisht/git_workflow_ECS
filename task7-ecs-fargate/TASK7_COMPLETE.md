# Task 7: Strapi on AWS ECS Fargate with GitHub Actions CI/CD

## Overview
This task demonstrates deploying a Strapi application on AWS ECS Fargate with complete CI/CD automation using GitHub Actions and Terraform.

## Architecture

### Infrastructure Components
- **ECS Fargate**: Serverless container orchestration
- **ECR**: Docker image registry
- **RDS PostgreSQL**: Database (15.10)
- **Default VPC**: Using existing VPC to save costs
- **Security Groups**: Network access control
- **IAM Roles**: Task execution and task roles

### Cost Optimization
- Using default VPC (saves ~$65/month on NAT Gateway)
- Single ECS task (1 vCPU, 1GB RAM)
- No Application Load Balancer (using public IP directly)
- No CloudWatch Logs (permission constraints)
- **Estimated cost**: ~$38/month or ~$3 for 2-3 days testing

## Deployment

### Prerequisites
1. AWS Account with appropriate permissions
2. GitHub repository
3. AWS CLI configured locally
4. Docker installed
5. Terraform installed

### Step 1: Infrastructure Setup

```bash
cd task7-ecs-fargate/terraform

# Initialize Terraform
terraform init

# Create S3 bucket for state (one-time)
aws s3 mb s3://arman-terraform-ecs-state --region ap-south-1

# Review plan
terraform plan

# Apply infrastructure
terraform apply
```

### Step 2: GitHub Secrets Configuration

Add these secrets to your GitHub repository:
- `AWS_ACCESS_KEY_ID`: Your AWS access key
- `AWS_SECRET_ACCESS_KEY`: Your AWS secret key

### Step 3: Build and Push Initial Image

```bash
cd task7-ecs-fargate

# Login to ECR
aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin 891377350540.dkr.ecr.ap-south-1.amazonaws.com

# Build image
docker build -t arman-strapi-fargate:latest .

# Tag for ECR
docker tag arman-strapi-fargate:latest 891377350540.dkr.ecr.ap-south-1.amazonaws.com/arman-strapi-fargate:latest

# Push to ECR
docker push 891377350540.dkr.ecr.ap-south-1.amazonaws.com/arman-strapi-fargate:latest
```

### Step 4: Force ECS Deployment

```bash
aws ecs update-service \
  --cluster arman-strapi-ecs-cluster \
  --service arman-strapi-ecs-service \
  --force-new-deployment \
  --region ap-south-1
```

### Step 5: Get Application URL

```bash
# List running tasks
aws ecs list-tasks \
  --cluster arman-strapi-ecs-cluster \
  --service-name arman-strapi-ecs-service \
  --region ap-south-1

# Get task details and public IP
TASK_ARN=$(aws ecs list-tasks --cluster arman-strapi-ecs-cluster --service-name arman-strapi-ecs-service --region ap-south-1 --query 'taskArns[0]' --output text)

ENI_ID=$(aws ecs describe-tasks --cluster arman-strapi-ecs-cluster --tasks $TASK_ARN --region ap-south-1 --query "tasks[0].attachments[0].details[?name=='networkInterfaceId'].value" --output text)

PUBLIC_IP=$(aws ec2 describe-network-interfaces --network-interface-ids $ENI_ID --region ap-south-1 --query "NetworkInterfaces[0].Association.PublicIp" --output text)

echo "Strapi URL: http://$PUBLIC_IP:1337"
```

## GitHub Actions Workflows

### CI Workflow (ecs-ci.yml)
**Trigger**: Push to `main` or `Arman_Bisht_v2` branches with changes in `task7-ecs-fargate/`

**Steps**:
1. Checkout code
2. Configure AWS credentials
3. Login to ECR
4. Build Docker image with commit SHA tag
5. Tag image as `latest`
6. Push both tags to ECR
7. Trigger CD workflow

### CD Workflow (ecs-cd.yml)
**Trigger**: Repository dispatch from CI workflow or manual workflow_dispatch

**Steps**:
1. Checkout code
2. Configure AWS credentials
3. Login to ECR
4. Download current ECS task definition
5. Update task definition with new image
6. Deploy to ECS service
7. Wait for service stability
8. Get task public IP
9. Display deployment summary

## Testing the CI/CD Pipeline

### Automatic Trigger
1. Make changes to files in `task7-ecs-fargate/`
2. Commit and push to `main` or `Arman_Bisht_v2` branch
3. GitHub Actions will automatically:
   - Build new Docker image
   - Push to ECR
   - Update ECS task definition
   - Deploy new version

### Manual Trigger
1. Go to GitHub Actions tab
2. Select "ECS CD - Deploy to Fargate"
3. Click "Run workflow"
4. Enter image tag (default: `latest`)
5. Click "Run workflow"

## Current Deployment

### Infrastructure Details
- **ECR Repository**: `891377350540.dkr.ecr.ap-south-1.amazonaws.com/arman-strapi-fargate`
- **ECS Cluster**: `arman-strapi-ecs-cluster`
- **ECS Service**: `arman-strapi-ecs-service`
- **RDS Endpoint**: `arman-strapi-ecs-postgres.cfoeec4ow9tb.ap-south-1.rds.amazonaws.com:5432`
- **Current Task IP**: `13.200.236.146:1337`

### Application Access
- **Strapi Admin**: http://13.200.236.146:1337/admin
- **Strapi API**: http://13.200.236.146:1337/api

**Note**: The public IP changes when tasks are restarted. Use the commands above to get the current IP.

## Troubleshooting

### Task Not Starting
```bash
# Check service events
aws ecs describe-services \
  --cluster arman-strapi-ecs-cluster \
  --services arman-strapi-ecs-service \
  --region ap-south-1 \
  --query "services[0].events[0:5]"

# Check stopped tasks
aws ecs list-tasks \
  --cluster arman-strapi-ecs-cluster \
  --service-name arman-strapi-ecs-service \
  --region ap-south-1 \
  --desired-status STOPPED

# Get task failure reason
aws ecs describe-tasks \
  --cluster arman-strapi-ecs-cluster \
  --tasks <TASK_ARN> \
  --region ap-south-1 \
  --query "tasks[0].{StoppedReason:stoppedReason,Containers:containers[0]}"
```

### Image Pull Errors
- Verify ECR repository exists
- Check IAM task execution role has ECR permissions
- Ensure image was pushed successfully

### Database Connection Issues
- Verify RDS security group allows traffic from ECS tasks
- Check database credentials in task definition
- Ensure RDS instance is available

## Cleanup

To avoid ongoing charges:

```bash
# Destroy infrastructure
cd task7-ecs-fargate/terraform
terraform destroy

# Delete S3 state bucket (optional)
aws s3 rb s3://arman-terraform-ecs-state --force --region ap-south-1

# Delete ECR images (optional)
aws ecr batch-delete-image \
  --repository-name arman-strapi-fargate \
  --image-ids imageTag=latest \
  --region ap-south-1
```

## Key Learnings

1. **Terraform State Management**: Using S3 backend for remote state storage
2. **ECS Fargate**: Serverless container deployment without managing EC2 instances
3. **GitHub Actions**: Automated CI/CD pipeline with AWS integration
4. **Docker Multi-stage**: Building optimized container images
5. **Cost Optimization**: Using default VPC and minimal resources
6. **Security**: IAM roles, security groups, and secret management

## Repository
- **Personal Repo**: https://github.com/Arman-Bisht/git_workflow_ECS.git
- **Branch**: main (from Arman_Bisht_v2)
