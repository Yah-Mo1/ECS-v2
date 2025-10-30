variable "env" {
  type        = string
  description = "The Environment the resources are created within"

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


