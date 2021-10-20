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

resource "aws_lb_target_group" "ecs" {
  name        = "ecs"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc.id
  target_type = "ip"

  health_check {
    enabled             = true
    interval            = 300
    path                = "/"
    timeout             = 60
    matcher             = "200"
    healthy_threshold   = 5
    unhealthy_threshold = 5
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
    type = "authenticate-cognito"

    authenticate_cognito {
      user_pool_arn       = var.cognito_pool.arn
      user_pool_client_id = var.cognito_client.id
      user_pool_domain    = var.cognito_domain.domain
    }
  }

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs.arn
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
