locals {
  target_groups = [
    "green",
    "blue",
  ]
}

resource "aws_lb_target_group" "this" {
  count = length(local.target_groups)

  name        = "${var.env}-alb-target-group-${local.target_groups[count.index]}"
  target_type = "ip"
  port        = 8000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id

  tags = {
    Environment = var.env
  }

  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 2
    interval            = 20
    timeout             = 3
    protocol            = "HTTP"
    path                = "/healthz"
    matcher             = "200"
  }

}


/*TODO: Test this!
resource "aws_lb_target_group" "this" {
name        = "${var.env}-alb-target-group"  
port     = 8000
  protocol = "HTTP"
  target_type = "ip"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/healthz"
    protocol            = "HTTP"
    port                = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 10
    matcher             = "200"
  }
}
*/