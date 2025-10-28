variable "env" {
  type        = string
  description = "The Environment the resources are created within"
}
variable "region" {
  type        = string
  description = "The region the VPC exists in"
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC"
}

variable "private_route_table_ids" {
  type        = list(string)
  description = "The IDs of the private route tables"
}
