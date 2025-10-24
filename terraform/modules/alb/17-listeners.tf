//ACM Certificate ARN

data "aws_acm_certificate" "this" {
  domain = var.domain
  types  = ["AMAZON_ISSUED"]
}


resource "aws_lb_listener" "HTTPS_Listener" {
  load_balancer_arn = aws_lb.this.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.this.arn

  default_action {
    type = "forward"

    forward {
      target_group {
        arn    = aws_lb_target_group.this[0].arn # Green target group
        weight = 100
      }
    }
  }
}

resource "aws_alb_listener" "l_8080" {
  load_balancer_arn = aws_lb.this.id
  port              = 8080
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[1].arn # Blue target group
  }
}


resource "aws_lb_listener" "HTTP_Listener" {
  load_balancer_arn = aws_lb.this.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

