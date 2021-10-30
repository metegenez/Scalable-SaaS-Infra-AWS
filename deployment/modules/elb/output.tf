output "elb" {
  value = aws_lb.elb
}

output "aws_backend_lb_listener" {
  value = aws_lb_listener.https
}

output "ecs_target_group_b" {
  value = aws_lb_target_group.target_b
}
output "ecs_target_group_a" {
  value = aws_lb_target_group.target_a
}
