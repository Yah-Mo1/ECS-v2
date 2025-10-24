#Dynamodb Table
resource "aws_dynamodb_table" "this" {
  name         = "${var.env}-dynamodb-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"
  attribute {
    name = "id"
    type = "S"
  }
  /*attribute {
    name = "url"
    type = "S"
  }*/

  tags = {
    Environment = var.env
  }

  region = var.region
}

#DynamoDB Endpoint
resource "aws_vpc_endpoint" "dynamodb_endpoint" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.region}.dynamodb"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = var.private_route_table_ids
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : "*",
        "Action" : "*",
        "Resource" : "*"
      }
    ]
  })
}