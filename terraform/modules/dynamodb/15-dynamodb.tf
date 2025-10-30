data "aws_caller_identity" "current" {}

#KMS key policy
data "aws_iam_policy_document" "kms_key_policy" {
  statement {
    sid    = "EnableRootPermissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }
}


#KMS key for DynamoDB
resource "aws_kms_key" "this" {
  description         = "KMS key for DynamoDB"
  enable_key_rotation = true
  policy              = data.aws_iam_policy_document.kms_key_policy.json
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

