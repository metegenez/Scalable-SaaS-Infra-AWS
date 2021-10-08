

resource "aws_ecs_task_definition" "node1" {
  family = "node1"
  container_definitions = jsonencode(
    [{
      "portMappings" : [
        {
          "hostPort" : 80,
          "protocol" : "tcp",
          "containerPort" : 80
        }
      ],
      "cpu" : 512,
      "environment" : [
        {
          "name" : "AUTHOR",
          "value" : "metegenez"
        }
      ],
      "memory" : 1024,
      "image" : "dockersamples/static-site",
      "essential" : true,
      "name" : "site"
  }])
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  memory                   = "1024"
  cpu                      = "512"
  execution_role_arn       = var.ecs_role.arn
  task_role_arn            = var.ecs_role.arn

  tags = {
    Project = "cloudvisor-${terraform.workspace}"
  }
}

resource "aws_ecs_service" "node1" {
  name             = "cloudvisor-node-${terraform.workspace}"
  cluster          = aws_ecs_cluster.node1.id
  task_definition  = aws_ecs_task_definition.node1.arn
  desired_count    = 1
  launch_type      = "FARGATE"
  platform_version = "1.4.0"

  lifecycle {
    ignore_changes = [desired_count]
  }

  network_configuration {
    subnets = [
      var.ecs_subnet_a.id,
      var.ecs_subnet_b.id,
    var.ecs_subnet_c.id]
    security_groups  = [var.ecs_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = var.ecs_target_group.arn
    container_name   = "site"
    container_port   = 80
  }
}

resource "aws_ecs_cluster" "node1" {
  name               = "cloudvisor-cluster-${terraform.workspace}"
  capacity_providers = ["FARGATE"]
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  tags = {
    "Project" = "cloudvisor-${terraform.workspace}"
  }
}
