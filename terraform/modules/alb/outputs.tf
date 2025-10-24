output "dns_name" {
  value = aws_lb.this.dns_name
}

output "zone_id" {
  value = aws_lb.this.zone_id
}

output "green_target_group_arn" {
  value = aws_lb_target_group.this[0].arn
}
output "blue_target_group_arn" {
  value = aws_lb_target_group.this[1].arn
}

output "alb_sg_id" {
  value = aws_security_group.lb_sg.id
}

output "https_listener_arn" {
  value = aws_lb_listener.HTTPS_Listener.arn
}

output "blue_target_group_name" {
  value = aws_lb_target_group.this[1].name
}

output "green_target_group_name" {
  value = aws_lb_target_group.this[0].name
}

output "alb_arn" {
  value = aws_lb.this.arn
}