# Variables for Terraform Configuration

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-south-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro" # 1GB RAM - minimal but works with 2GB swap
}

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
}


