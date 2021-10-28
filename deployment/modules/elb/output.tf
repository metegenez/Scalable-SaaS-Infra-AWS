output "elb" {
  value = aws_lb.elb
}

output "ecs_target_group" {
  value = aws_lb_target_group.ecs
}

output "ecs_test_target_group" {
  value = aws_lb_target_group.backend-green
}

output "aws_backend_lb_listener" {
  value = aws_lb_listener.https
}

