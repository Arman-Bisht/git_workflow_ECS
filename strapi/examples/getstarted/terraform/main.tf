# Terraform Configuration for Strapi Deployment on EC2
# Task 5: Deploy Strapi using Terraform and Docker

terraform {
  required_version = ">= 1.0"
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

# Use Default VPC and Subnet
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}



# Security Group for EC2
resource "aws_security_group" "strapi_sg" {
  name        = "strapi-security-group-v2"
  description = "Security group for Strapi application"
  vpc_id      = data.aws_vpc.default.id

  # SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH access"
  }

  # Strapi application port
  ingress {
    from_port   = 1337
    to_port     = 1337
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Strapi application"
  }

  # HTTP access
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP access"
  }

  # Outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "strapi-sg"
  }
}

# Security Group for RDS
resource "aws_security_group" "rds_sg" {
  name        = "strapi-rds-sg"
  description = "Security group for RDS PostgreSQL"
  vpc_id      = data.aws_vpc.default.id

  # PostgreSQL access from EC2
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.strapi_sg.id]
    description     = "PostgreSQL access from EC2"
  }

  # Outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "strapi-rds-sg"
  }
}



# Data source for availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# Data source for latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# IAM Role for EC2 to access ECR
resource "aws_iam_role" "ec2_ecr_role" {
  name = "strapi-ec2-ecr-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "strapi-ec2-ecr-role"
  }
}

# Attach ECR read-only policy to the role
resource "aws_iam_role_policy_attachment" "ecr_read_only" {
  role       = aws_iam_role.ec2_ecr_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Create instance profile
resource "aws_iam_instance_profile" "ec2_ecr_profile" {
  name = "strapi-ec2-ecr-profile"
  role = aws_iam_role.ec2_ecr_role.name
}

# DB Subnet Group for RDS
resource "aws_db_subnet_group" "strapi_db_subnet" {
  name       = "strapi-db-subnet"
  subnet_ids = data.aws_subnets.default.ids

  tags = {
    Name = "strapi-db-subnet"
  }
}

# RDS PostgreSQL Instance
resource "aws_db_instance" "strapi_db" {
  identifier             = "strapi-postgres"
  engine                 = "postgres"
  engine_version         = "15.4"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  storage_type           = "gp3"
  db_name                = "strapi"
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.strapi_db_subnet.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  publicly_accessible    = false
  skip_final_snapshot    = true
  backup_retention_period = 7
  
  tags = {
    Name = "strapi-postgres"
  }
}

# EC2 Instance
resource "aws_instance" "strapi_instance" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.instance_type
  subnet_id              = data.aws_subnets.default.ids[0]
  vpc_security_group_ids = [aws_security_group.strapi_sg.id]
  key_name               = var.key_name != "" ? var.key_name : null
  iam_instance_profile   = aws_iam_instance_profile.ec2_ecr_profile.name

  user_data = templatefile("${path.module}/user_data.sh", {
    db_host     = aws_db_instance.strapi_db.address
    db_port     = aws_db_instance.strapi_db.port
    db_name     = aws_db_instance.strapi_db.db_name
    db_username = var.db_username
    db_password = var.db_password
  })

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  tags = {
    Name = "Arman"
  }
  
  depends_on = [aws_db_instance.strapi_db]
}
