resource "aws_lb" "elb" {
  name               = "elb-${terraform.workspace}"
  internal           = false
  load_balancer_type = "application"
  security_groups = [
  var.load_balancer_sg.id]
  subnets = [
    var.load_balancer_subnet_a.id,
    var.load_balancer_subnet_b.id,
  var.load_balancer_subnet_c.id]

  tags = {
    Project = "cloudvisor-${terraform.workspace}"
  }
}

resource "aws_lb_target_group" "target_b" {
  name        = "backend-target-b-${terraform.workspace}-${substr(uuid(), 0, 3)}"
  port        = 8000
  protocol    = "HTTP"
  vpc_id      = var.vpc.id
  target_type = "ip"
  lifecycle {
    create_before_destroy = true
    ignore_changes        = [name]
  }
  health_check {
    interval            = 300
    timeout             = 120
    unhealthy_threshold = 10
    path                = "/healthcheck/"
  }

  tags = {
    Project = "cloudvisor-${terraform.workspace}"
  }
}

resource "aws_lb_target_group" "target_a" {
  name        = "backend-target-a-${terraform.workspace}-${substr(uuid(), 0, 3)}"
  port        = 8000
  protocol    = "HTTP"
  vpc_id      = var.vpc.id
  target_type = "ip"
  lifecycle {
    create_before_destroy = true
    ignore_changes        = [name]
  }
  health_check {
    interval            = 300
    timeout             = 120
    unhealthy_threshold = 10
    path                = "/healthcheck/"
  }

  tags = {
    Project = "cloudvisor-${terraform.workspace}"
  }
}


resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.elb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.acm_certificate

  default_action {
    type             = "forward"
    target_group_arn = var.current_deployment_state == "A" ? aws_lb_target_group.target_a.arn : aws_lb_target_group.target_b.arn
  }
}



resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.elb.arn
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
