[
  {
    "name": "${container_name}",
    "image": "${image_url}:latest",
    "cpu": ${cpu},
    "memory": ${memory},
    "essential": true,
    "portMappings": [
      {
        "containerPort": 8000,
        "hostPort": 8000
      }
    ],
    "environment": ${jsonencode(environment)},
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${ecs_log_group}",
        "awslogs-region": "eu-west-2",
        "awslogs-stream-prefix": "${logs_prefix}"
      }
    }
  }
]