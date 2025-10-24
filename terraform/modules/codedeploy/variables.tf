variable "env" {
  type        = string
  description = "The Environment the resources are created within"
}

variable "service_role_arn" {
  type        = string
  description = "The ARN of the service role"
}

variable "ecs_cluster_name" {
  type        = string
  description = "The name of the ECS cluster"
}

variable "ecs_service_name" {
  type        = string
  description = "The name of the ECS service"
}

variable "https_listener_arn" {
  type        = string
  description = "The ARN of the HTTPS listener"
}

variable "blue_target_group_name" {
  type        = string
  description = "The name of the blue target group"
}

variable "green_target_group_name" {
  type        = string
  description = "The name of the green target group"
}

variable "region" {
  type        = string
  description = "The region the resources are created in"

}

variable "ecs_execution_role" {
  type        = string
  description = "The ARN of the ECS execution role"
}


variable "ecs_service_id" {
  type        = string
  description = "The ARN of the ECS service"
}