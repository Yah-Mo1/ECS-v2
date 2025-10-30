data "aws_caller_identity" "current" {}

resource "aws_iam_role" "ecs_task_role" {
  name = "${var.env}-ecs-task-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow",
        Principal = { Service = "ecs-tasks.amazonaws.com" },
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

data "aws_iam_policy_document" "task_ddb" {
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DescribeTable"
    ]
    resources = [
      "arn:aws:dynamodb:${var.region}:${data.aws_caller_identity.current.account_id}:table/${var.dynamodb_table_name}"
    ]
  }
}

resource "aws_iam_role_policy" "ecs_task_role_ddb" {
  role   = aws_iam_role.ecs_task_role.id
  policy = data.aws_iam_policy_document.task_ddb.json
}

# KMS usage policy for the DDB CMK (required because table uses CMK)
data "aws_iam_policy_document" "kms_for_ddb" {
  statement {
    sid    = "AllowUseOfDDBCMK"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:DescribeKey",
      "kms:GenerateDataKey",
      "kms:GenerateDataKeyWithoutPlaintext",
      "kms:ReEncryptFrom",
      "kms:ReEncryptTo"
    ]
    resources = [var.kms_key_arn]

    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["dynamodb.${var.region}.amazonaws.com"]
    }

  }
}

resource "aws_iam_policy" "kms_for_ddb" {
  name   = "${var.env}-ecs-kms-for-ddb"
  policy = data.aws_iam_policy_document.kms_for_ddb.json
}

resource "aws_iam_role_policy_attachment" "task_kms_attach" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.kms_for_ddb.arn
}




#ECS Execution Role 

resource "aws_iam_role" "ecs_execution_role" {
  name = "${var.env}-ecs-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow",
        Principal = { Service = "ecs-tasks.amazonaws.com" },
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}



#KMS key for CloudWatch Logs
resource "aws_kms_key" "cloudwatch_kms_key" {
  description         = "KMS key for CloudWatch Logs"
  enable_key_rotation = true

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Id" : "key-default-1",
    "Statement" : [
      {
        "Sid" : "Enable IAM User Permissions",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        "Action" : "kms:*",
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "logs.${var.region}.amazonaws.com"
        },
        "Action" : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:Describe*"
        ],
        "Resource" : "*",
        "Condition" : {
          "ArnEquals" : {
            "kms:EncryptionContext:aws:logs:arn" : "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:ecs-log-group"
          }
        }
      }
    ]
    }
  )
  tags = {
    Environment = var.env
  }
}



#CloudWatch Log Group
resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name = "ecs-log-group"

  retention_in_days = 365
  kms_key_id        = aws_kms_key.cloudwatch_kms_key.arn

  tags = {
    Environment = var.env
  }
  depends_on = [aws_kms_key.cloudwatch_kms_key]
}

resource "aws_security_group" "ecs_task_sg" {
  name        = "${var.env}-ecs-task-sg"
  vpc_id      = var.vpc_id
  description = "Security group for the ECS task"
  tags = {
    Environment = var.env
  }

  ingress {
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
    security_groups = [var.alb_sg_id]
    description     = "Allow the ECS task to communicate with the ALB"
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow the ECS task to communicate with the internet"
  }

}


resource "aws_ecs_task_definition" "ecs-task-definition" {
  family                   = "${var.env}-ecs-task-definition"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  cpu                      = var.ecs_task_cpu
  memory                   = var.ecs_task_memory
  container_definitions = templatefile("${path.module}/task_def_init.tpl", {
    container_name = var.container_name
    image_url      = data.aws_ecr_repository.this.repository_url
    cpu            = var.ecs_container_cpu
    memory         = var.ecs_container_memory
    ecs_log_group  = aws_cloudwatch_log_group.ecs_log_group.name
    logs_prefix    = aws_cloudwatch_log_group.ecs_log_group.name
    environment = [
      { name = "TABLE_NAME", value = var.dynamodb_table_name },
      { name = "AWS_REGION", value = var.region },
    ]
  })
  runtime_platform {
    operating_system_family = var.operating_system_family
    cpu_architecture        = var.cpu_architecture
  }

}




resource "aws_ecs_task_definition" "ecs-task-definition-production" {
  family                   = "${var.env}-ecs-task-definition-production"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  cpu                      = var.ecs_task_cpu
  memory                   = var.ecs_task_memory
  container_definitions = templatefile("${path.module}/task_def_init.tpl", {
    container_name = var.container_name
    image_url      = "982081079659.dkr.ecr.eu-west-2.amazonaws.com/ecs-v2-ecr:latest"
    cpu            = var.ecs_container_cpu
    memory         = var.ecs_container_memory
    ecs_log_group  = aws_cloudwatch_log_group.ecs_log_group.name
    logs_prefix    = aws_cloudwatch_log_group.ecs_log_group.name
    environment = [
      { name = "TABLE_NAME", value = var.dynamodb_table_name },
      { name = "AWS_REGION", value = var.region },
    ]
  })
  runtime_platform {
    operating_system_family = var.operating_system_family
    cpu_architecture        = var.cpu_architecture
  }

}

