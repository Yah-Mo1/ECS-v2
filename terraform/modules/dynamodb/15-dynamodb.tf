resource "aws_kms_key" "this" {
  description         = "KMS key for DynamoDB"
  enable_key_rotation = true
  tags = {
    Environment = var.env
  }
}

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

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.this.arn
  }

  region = var.region
}

