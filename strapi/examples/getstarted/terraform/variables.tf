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
  description = "Name of the SSH key pair (optional - leave empty to use EC2 Instance Connect)"
  type        = string
  default     = ""
}



variable "db_username" {
  description = "Database master username"
  type        = string
  default     = "strapi"
  sensitive   = true
}

variable "db_password" {
  description = "Database master password"
  type        = string
  default     = "strapi123456"
  sensitive   = true
}
