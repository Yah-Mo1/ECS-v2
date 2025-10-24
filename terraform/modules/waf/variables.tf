variable "env" {
  type        = string
  description = "The Environment the resources are created within"

}

variable "region" {
  type        = string
  description = "The region the VPC exists in"

}

variable "resource_arn" {
  type        = string
  description = "The ARN of the resource to associate the WAF with"
}