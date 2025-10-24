
//Networking Module

variable "env" {
  type        = string
  description = "The Environment the resources are created within"

}

variable "region" {
  type        = string
  description = "The region the VPC exists in"

}

variable "vpc_cidr_block" {
  type        = string
  description = "The CIDR block for the VPC"
}

variable "public_subnet_cidr_block" {
  type        = list(string)
  description = "The CIDR block for the public subnet"
}


variable "private_subnet_cidr_block" {
  type        = list(string)
  description = "The CIDR block for the private subnet"
}

variable "sg_name" {
  type        = string
  description = "The name of the security group"

}


//ECS Module

variable "ecr_repository_name" {
  type        = string
  description = "The name of the ECR repository"
}

variable "ecs_cluster_name" {
  type        = string
  description = "The name of the ECS cluster"
}

variable "operating_system_family" {
  type        = string
  description = "The operating system family of the ECS cluster"
}

variable "ecs_service_name" {
  type        = string
  description = "The name of the ECS service"
}

variable "ecs_container_memory" {
  type        = number
  description = "The memory of the ECS container"
}

variable "ecs_container_cpu" {
  type        = number
  description = "The CPU of the ECS container"
}

variable "ecs_task_cpu" {
  type        = number
  description = "The CPU of the ECS task"
}

variable "ecs_task_memory" {
  type        = number
  description = "The memory of the ECS task"
}

variable "container_name" {
  type        = string
  description = "The name of the container"
}

variable "container_port" {
  type        = number
  description = "The port of the container"
}

variable "desired_count" {
  type        = number
  description = "The desired count of the ECS service"
}

variable "cpu_architecture" {
  type        = string
  description = "The CPU architecture of the ECS task"
}

variable "ecs_service_role_name" {
  type        = string
  description = "The name of the ECS service role"
}

variable "ecs_execution_role_name" {
  type        = string
  description = "The name of the ECS execution role"
}

variable "ecs_task_role_name" {
  type        = string
  description = "The name of the ECS task role"
}


//ALB Module

variable "lb_name" {
  type        = string
  description = "The name of the ALB"
}

variable "domain" {
  type        = string
  description = "The domain of the ALB"
}

// DynamoDB Module

variable "dynamodb_table_name" {
  type        = string
  description = "The name of the DynamoDB table"
}


//Autoscaling Module

variable "max_capacity" {
  type        = number
  description = "The maximum number of instances to scale up to"
}

variable "min_capacity" {
  type        = number
  description = "The minimum number of instances to scale down to"
}