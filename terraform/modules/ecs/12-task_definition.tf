data "aws_iam_role" "ecs_execution_role" {
  name = var.ecs_execution_role_name
}


resource "aws_cloudwatch_log_group" "this" {
  name = "${var.env}-ecs-log-group"
  tags = {
    Environment = var.env
  }
}

resource "aws_security_group" "ecs_task_sg" {
  name   = "${var.env}-ecs-task-sg"
  vpc_id = var.vpc_id
  tags = {
    Environment = var.env
  }

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    security_groups = [var.alb_sg_id]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}


//TODO: Work on setting this up!
resource "aws_ecs_task_definition" "ecs-task-definition" {
  family                   = "${var.env}-ecs-task-definition"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = data.aws_iam_role.ecs_execution_role.arn
  cpu                      = var.ecs_task_cpu
  memory                   = var.ecs_task_memory
  container_definitions = templatefile("${path.module}/task_def_init.tpl", {
    container_name = var.container_name
    image_url      = data.aws_ecr_repository.this.repository_url
    cpu            = var.ecs_container_cpu
    memory         = var.ecs_container_memory
    ecs_log_group  = aws_cloudwatch_log_group.this.name
    logs_prefix    = aws_cloudwatch_log_group.this.name
    environment = [
      { name = "TABLE_NAME", value = var.dynamodb_table_name },
      { name = "AWS_REGION", value = var.region }
    ]
  })
  runtime_platform {
    operating_system_family = var.operating_system_family
    cpu_architecture        = var.cpu_architecture
  }

}
