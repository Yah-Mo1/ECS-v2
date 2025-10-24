output "ecs_cluster_name" {
  value = aws_ecs_cluster.this.name
}

output "ecs_service_name" {
  value = aws_ecs_service.this.name
}

output "ecs_service_role_arn" {
  value = data.aws_iam_role.ecs_service_role.arn
}

output "ecs_service_id" {
  value = aws_ecs_service.this.id
}

output "ecs_execution_role_arn" {
  value = data.aws_iam_role.ecs_execution_role.arn
}