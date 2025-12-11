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

# Create Docker network
echo "Creating Docker network..."
docker network create strapi-network

# Pull PostgreSQL image
echo "Pulling PostgreSQL Docker image..."
docker pull postgres:15-alpine

# Run PostgreSQL container
echo "Starting PostgreSQL container..."
docker run -d \
  --name strapi-postgres \
  --network strapi-network \
  --restart unless-stopped \
  -e POSTGRES_USER=strapi \
  -e POSTGRES_PASSWORD=strapi123 \
  -e POSTGRES_DB=strapi \
  -v postgres-data:/var/lib/postgresql/data \
  postgres:15-alpine

# Wait for PostgreSQL to be ready
echo "Waiting for PostgreSQL to be ready..."
sleep 15

# Pull Strapi image from ECR (public access)
echo "Pulling Strapi Docker image from ECR..."
docker pull 301782007642.dkr.ecr.ap-south-1.amazonaws.com/strapi-app:latest

# Run Strapi container with PostgreSQL connection
echo "Starting Strapi container with PostgreSQL..."
docker run -d \
  --name strapi-app \
  --network strapi-network \
  --restart unless-stopped \
  -p 1337:1337 \
  -e DATABASE_CLIENT=postgres \
  -e DATABASE_HOST=strapi-postgres \
  -e DATABASE_PORT=5432 \
  -e DATABASE_NAME=strapi \
  -e DATABASE_USERNAME=strapi \
  -e DATABASE_PASSWORD=strapi123 \
  -e NODE_ENV=production \
  -e APP_KEYS=toBeModified1,toBeModified2 \
  -e API_TOKEN_SALT=tobemodified \
  -e ADMIN_JWT_SECRET=tobemodified \
  -e TRANSFER_TOKEN_SALT=tobemodified \
  -e JWT_SECRET=tobemodified \
  301782007642.dkr.ecr.ap-south-1.amazonaws.com/strapi-app:latest

echo "Strapi deployment completed!"
echo "PostgreSQL running in Docker container"
echo "Strapi connected to local PostgreSQL"

# Log container status
docker ps
docker logs strapi-postgres
docker logs strapi-app
