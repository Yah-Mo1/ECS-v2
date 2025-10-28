data "aws_caller_identity" "current" {}

resource "aws_security_group" "lb_sg" {
  name        = "${var.env}-lb-sg"
  vpc_id      = var.vpc_id
  description = "Security group for the ALB"
  tags = {
    Environment = var.env
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#KMS key for ALB Logs
resource "aws_kms_key" "lb_kms_key" {
  description         = "KMS key for ALB Logs"
  enable_key_rotation = true
  tags = {
    Environment = var.env
  }
}

resource "aws_s3_bucket" "lb_logs" {
  bucket = "${var.env}-lb-logs"
  tags = {
    Environment = var.env
  }

}


resource "aws_s3_bucket_policy" "lb_logs_policy" {
  bucket = aws_s3_bucket.lb_logs.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "logdelivery.elasticloadbalancing.amazonaws.com"
        },
        Action = "s3:PutObject",
        Resource = "arn:aws:s3:::${aws_s3_bucket.lb_logs.bucket}/prefix/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
      }
    ]
  })
}

resource "aws_lb" "this" {
  name               = var.lb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = var.public_subnet_ids

  # access_logs {
  #   bucket  = aws_s3_bucket.lb_logs.bucket
  #   prefix  = "${var.env}-lb-logs"
  #   enabled = true
  # }

  enable_deletion_protection = false
  drop_invalid_header_fields = true


  tags = {
    Environment = var.env
  }
}