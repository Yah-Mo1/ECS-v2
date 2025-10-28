resource "aws_ecs_service" "this" {
  name             = var.ecs_service_name
  cluster          = var.ecs_cluster_name
  task_definition  = aws_ecs_task_definition.ecs-task-definition.arn
  desired_count    = var.desired_count
  launch_type      = "FARGATE"
  platform_version = "LATEST"
  enable_execute_command = true

  deployment_controller {
    type = "CODE_DEPLOY"
  }
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 50

  network_configuration {
    subnets          = var.private_subnet_ids
    assign_public_ip = false
    security_groups  = [aws_security_group.ecs_task_sg.id]
  }

  load_balancer {
    target_group_arn = var.green_target_group_arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

  lifecycle {
    ignore_changes = [
      task_definition,
      load_balancer,
      platform_version,
      desired_count
    ]
  }
}