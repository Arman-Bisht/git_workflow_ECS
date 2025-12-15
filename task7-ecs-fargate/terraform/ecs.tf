# ECS Cluster and Service

resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name = "${var.project_name}-cluster"
  }
}

resource "aws_ecs_task_definition" "strapi" {
  family                   = "${var.project_name}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([{
    name  = "strapi"
    image = "${aws_ecr_repository.strapi.repository_url}:latest"
    
    portMappings = [{
      containerPort = 1337
      protocol      = "tcp"
    }]

    environment = [
      { name = "NODE_ENV", value = "development" },
      { name = "APP_KEYS", value = "toBeModified1,toBeModified2" },
      { name = "API_TOKEN_SALT", value = "tobemodified" },
      { name = "ADMIN_JWT_SECRET", value = "tobemodified" },
      { name = "TRANSFER_TOKEN_SALT", value = "tobemodified" },
      { name = "JWT_SECRET", value = "tobemodified" },
      { name = "HOST", value = "0.0.0.0" },
      { name = "PORT", value = "1337" }
    ]
  }])

  tags = {
    Name = "${var.project_name}-task"
  }
}


resource "aws_ecs_service" "strapi" {
  name            = "${var.project_name}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.strapi.arn
  desired_count   = var.app_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = data.aws_subnets.default.ids
    assign_public_ip = true
  }

  depends_on = [aws_iam_role_policy_attachment.ecs_task_execution]

  tags = {
    Name = "${var.project_name}-service"
  }
}
