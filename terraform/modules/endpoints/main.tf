#VPC Endpoints Security Group
resource "aws_security_group" "vpc_endpoints" {
  name_prefix = "${var.env}-vpc-endpoints"
  description = "Associated to ECR/s3 VPC Endpoints"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow Nodes to pull images from ECR via VPC endpoints"
    protocol        = "tcp"
    from_port       = 443
    to_port         = 443
    security_groups = [var.ecs_task_sg_id]
  }
}

#ECR VPC Endpoint
resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  security_group_ids = [aws_security_group.vpc_endpoints.id]
  subnet_ids         = var.private_subnet_ids

  tags = {
    "Name" = "${var.env}-ecr-dkr"
  }
}

#ECR API VPC Endpoint
resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  security_group_ids = [aws_security_group.vpc_endpoints.id]
  subnet_ids         = var.private_subnet_ids

  tags = {
    "Name" = "${var.env}-ecr-api"
  }
}

#S3 VPC Endpoint
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = var.private_route_table_ids

  tags = {
    "Name" = "${var.env}-s3"
  }
}


#DynamoDB VPC Endpoint
resource "aws_vpc_endpoint" "dynamodb_endpoint" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.region}.dynamodb"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = var.private_route_table_ids
}
