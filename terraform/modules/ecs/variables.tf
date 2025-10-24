variable "env" {
  type        = string
  description = "The Environment the resources are created within"

}

variable "region" {
  type        = string
  description = "The region the VPC exists in"

}

variable "ecr_repository_name" {
  type        = string
  description = "The name of the ECR repository"
}

variable "ecs_cluster_name" {
  type        = string
  description = "The name of the ECS cluster"
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC"

}

variable "private_subnet_ids" {
  type        = list(string)
  description = "The IDs of the private subnets"
}

variable "ecs_task_cpu" {
  type        = number
  description = "The CPU of the ECS task"
}

variable "ecs_task_memory" {
  type        = number
  description = "The memory of the ECS task"
}


variable "ecs_container_cpu" {
  type        = number
  description = "The CPU of the ECS container"
}

variable "ecs_container_memory" {
  type        = number
  description = "The memory of the ECS container"
}
variable "operating_system_family" {
  type        = string
  description = "The operating system family of the ECS task"
}

variable "cpu_architecture" {
  type        = string
  description = "The CPU architecture of the ECS task"
}

variable "ecs_execution_role_name" {
  type        = string
  description = "The name of the ECS execution role"
}

variable "ecs_service_role_name" {
  type        = string
  description = "The name of the ECS service role"
}

variable "ecs_service_name" {
  type        = string
  description = "The name of the ECS service"
}

variable "desired_count" {
  type        = number
  description = "The desired count of the ECS service"
}

variable "container_name" {
  type        = string
  description = "The name of the container"
}

variable "green_target_group_arn" {
  type        = string
  description = "The ARN of the target group"
}

variable "container_port" {
  type        = number
  description = "The port of the container"
}

variable "private_route_table_ids" {
  type        = list(string)
  description = "The IDs of the private route tables"
}

variable "dynamodb_table_name" {
  type        = string
  description = "The name of the DynamoDB table"
}

variable "alb_sg_id" {
  type        = string
  description = "The ID of the ALB security group"
}