# Task 7: ECS Fargate Deployment with Terraform
# Strapi on AWS ECS Fargate - Simplified

terraform {
  required_version = ">= 1.0"
  
  backend "s3" {
    bucket  = "arman-terraform-ecs-state"
    key     = "ecs-fargate/terraform.tfstate"
    region  = "ap-south-1"
    encrypt = true
  }
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Data sources for default VPC
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}
