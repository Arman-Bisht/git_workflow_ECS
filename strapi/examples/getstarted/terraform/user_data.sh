#!/bin/bash
# User Data Script for EC2 Instance
# This script runs automatically when the instance starts

set -e

# Update system
echo "Updating system packages..."
dnf update -y

# Install Docker
echo "Installing Docker..."
dnf install -y docker git

# Start Docker service
echo "Starting Docker service..."
systemctl start docker
systemctl enable docker

# Add ec2-user to docker group
usermod -aG docker ec2-user

# Install Docker Compose
echo "Installing Docker Compose..."
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Install EC2 Instance Connect for browser-based SSH
echo "Installing EC2 Instance Connect..."
dnf install -y ec2-instance-connect

# Create swap space (2GB) for better memory management
echo "Creating swap space..."
dd if=/dev/zero of=/swapfile bs=1M count=2048
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap sw 0 0' >> /etc/fstab

# Wait for RDS to be ready
echo "Waiting for RDS PostgreSQL to be ready..."
sleep 30

# Install AWS CLI v2
echo "Installing AWS CLI..."
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
dnf install -y unzip
unzip -q awscliv2.zip
./aws/install
rm -rf aws awscliv2.zip

# Login to ECR
echo "Logging in to ECR..."
aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin 301782007642.dkr.ecr.ap-south-1.amazonaws.com

# Pull Strapi image from ECR
echo "Pulling Strapi Docker image from ECR..."
docker pull 301782007642.dkr.ecr.ap-south-1.amazonaws.com/arman:latest

# Run Strapi container with RDS PostgreSQL connection
echo "Starting Strapi container with RDS PostgreSQL..."
docker run -d \
  --name strapi-app \
  --restart unless-stopped \
  -p 1337:1337 \
  -e DATABASE_CLIENT=postgres \
  -e DATABASE_HOST=${db_host} \
  -e DATABASE_PORT=${db_port} \
  -e DATABASE_NAME=${db_name} \
  -e DATABASE_USERNAME=${db_username} \
  -e DATABASE_PASSWORD=${db_password} \
  -e NODE_ENV=production \
  -e APP_KEYS=toBeModified1,toBeModified2 \
  -e API_TOKEN_SALT=tobemodified \
  -e ADMIN_JWT_SECRET=tobemodified \
  -e TRANSFER_TOKEN_SALT=tobemodified \
  -e JWT_SECRET=tobemodified \
  301782007642.dkr.ecr.ap-south-1.amazonaws.com/arman:latest

echo "Strapi deployment completed!"
echo "Strapi connected to RDS PostgreSQL at ${db_host}"

# Log container status
docker ps
docker logs strapi-app
