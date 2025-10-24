variable "env" {
  type        = string
  description = "The Environment the resources are created within"
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "The IDs of the public subnets"
}

variable "lb_name" {
  type        = string
  description = "The name of the LB"
}

variable "domain" {
  type        = string
  description = "The domain of the LB"
}