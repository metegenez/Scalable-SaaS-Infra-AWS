

data "aws_region" "current" {}

data "aws_secretsmanager_secret" "by-arn" {
  arn = var.aws_secret_manager_secret_arn
}

data "aws_secretsmanager_secret_version" "secret" {
  secret_id = data.aws_secretsmanager_secret.by-arn.id
}

resource "aws_cloudwatch_log_group" "LogGroup" {
  name              = "cloudvisor-node-${terraform.workspace}"
  retention_in_days = 731

  tags = {
    Project = "cloudvisor-${terraform.workspace}"
  }
}

resource "aws_ecs_task_definition" "node1" {
  family = "node1"
  container_definitions = jsonencode(
    [{
      Command : [
        "bash",
        "-c",
        "python3 manage.py makemigrations",
        "python3 manage.py migrate",
        "python3 manage.py runserver 0.0.0.0:8000 "
      ],
      "secrets" : [{
        "name" : "secret",
        "valueFrom" : "${var.aws_secret_manager_secret_arn}"
        }],
      PortMappings : [
        {
          ContainerPort : 8000,
          HostPort : 8000,
          Protocol : "tcp"
        }
      ],
      "cpu" : 512,
      "environment" : [
        {
          "name" : "STAGE",
          "value" : "${terraform.workspace}" //Findout settings from stage.
        },
        {
          "name" : "API_URL",
          "value" : "https://${var.backend_sub_domain_prefix}-${terraform.workspace}.${var.domain_name}"
        },
        {
          "name" : "DB_NAME",
          "value" : "${var.aws_rds_cluster_name}" //Findout settings from stage.
        },
        {
          "name" : "RO_DB_NAME",
          "value" : "${var.aws_rds_cluster_ro_host}" //Findout settings from stage.
        },
        {
          "name" : "DB_HOST",
          "value" : "${var.aws_rds_cluster_host}" //Findout settings from stage.
        },

      ],
      LogConfiguration : {
        LogDriver : "awslogs",
        Options : {
          awslogs-group : "cloudvisor-node-${terraform.workspace}",
          awslogs-region : data.aws_region.current.name,
          awslogs-stream-prefix : "cloudvisor-node-${terraform.workspace}"
        }
      },
      "memory" : 1024,
      "image" : "${var.backend_ecr.repository_url}",
      "essential" : true,
      "name" : "backend"
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
  name                               = "cloudvisor-node-${terraform.workspace}"
  cluster                            = aws_ecs_cluster.node1.id
  task_definition                    = aws_ecs_task_definition.node1.arn
  desired_count                      = 1
  launch_type                        = "FARGATE"
  platform_version                   = "1.4.0"
  propagate_tags                     = "SERVICE"
  scheduling_strategy                = "REPLICA"
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  force_new_deployment               = false
  lifecycle {
    ignore_changes = [desired_count, task_definition, load_balancer]
  }

  deployment_controller {
    type = "CODE_DEPLOY"
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
    target_group_arn = var.ecs_target_group_a.arn
    container_name   = "backend"
    container_port   = 8000
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
