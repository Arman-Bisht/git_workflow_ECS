# Variables for ECS Fargate Deployment

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "arman-strapi-ecs"
}

variable "ecr_repository_name" {
  description = "ECR repository name"
  type        = string
  default     = "arman-strapi-fargate"
}

variable "fargate_cpu" {
  description = "Fargate CPU units"
  type        = string
  default     = "512"
}

variable "fargate_memory" {
  description = "Fargate memory in MB"
  type        = string
  default     = "1024"
}

variable "app_count" {
  description = "Number of ECS tasks to run"
  type        = number
  default     = 1
}
