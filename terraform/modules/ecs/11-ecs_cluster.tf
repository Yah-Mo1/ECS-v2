data "aws_ecr_repository" "this" {
  name = var.ecr_repository_name
}



resource "aws_ecs_cluster" "this" {
  name = "${var.env}-${var.ecs_cluster_name}"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}


resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name = aws_ecs_cluster.this.name

  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}