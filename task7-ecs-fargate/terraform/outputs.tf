# Outputs

output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = aws_ecr_repository.strapi.repository_url
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  description = "ECS service name"
  value       = aws_ecs_service.strapi.name
}

output "access_instructions" {
  description = "How to access the application"
  value       = "Get task public IP from ECS console or use AWS CLI to find running tasks"
}
