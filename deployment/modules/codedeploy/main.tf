data "aws_secretsmanager_secret" "by-arn" {
  arn = var.aws_secret_manager_secret_arn
}

data "aws_secretsmanager_secret_version" "secret" {
  secret_id = data.aws_secretsmanager_secret.by-arn.id
}

resource "aws_iam_role" "CodeBuildRole" {
  name               = "cloudvisor-CodeBuildRole-${terraform.workspace}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "codebuild-policy-attachments" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess",
    "arn:aws:iam::aws:policy/AmazonECS_FullAccess",
    "arn:aws:iam::aws:policy/AWSCodeBuildAdminAccess",
    "arn:aws:iam::aws:policy/CloudWatchFullAccess",
    "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
  ])
  role       = aws_iam_role.CodeBuildRole.name
  policy_arn = each.value
}
resource "aws_iam_role_policy" "s3" {
  role = aws_iam_role.CodeBuildRole.name

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": [
        "${aws_s3_bucket.deployment.arn}",
        "${aws_s3_bucket.deployment.arn}/*"
      ]
    }
  ]
}
POLICY
}
resource "aws_codebuild_source_credential" "GithubCredentials" {
  auth_type   = "PERSONAL_ACCESS_TOKEN"
  server_type = "GITHUB"
  token       = jsondecode(data.aws_secretsmanager_secret_version.secret.secret_string)["github_personal_token"]
}

resource "aws_codebuild_webhook" "BackendCodeBuildWebHook" {
  project_name = aws_codebuild_project.BackendCodeBuild.name


  dynamic "filter_group" {
    for_each = terraform.workspace == "dev" ? ["1"] : ["1"]
    content {
      filter {
        type    = "EVENT"
        pattern = "PUSH"
      }

      filter {
        type    = "HEAD_REF"
        pattern = lookup(var.branch, terraform.workspace, "dev")
      }

      filter {
        type    = "FILE_PATH"
        pattern = "backend/*"
      }
    }
  }

  dynamic "filter_group" {
    for_each = terraform.workspace != "dev" ? [] : []
    content {
      filter {
        type    = "EVENT"
        pattern = "PULL_REQUEST_MERGED"
      }

      filter {
        type    = "HEAD_REF"
        pattern = lookup(var.branch, terraform.workspace, "dev")
      }

      filter {
        type    = "FILE_PATH"
        pattern = "backend/*"
      }
    }
  }


}


resource "aws_s3_bucket" "deployment" {
  bucket = "cloudvisor-${terraform.workspace}-deploy"
  acl    = "private"

  tags = {
    Project = "cloudvisor-${terraform.workspace}"
  }
}

resource "aws_ecr_repository" "backend" {
  name                 = "cloudvisor-backend-${terraform.workspace}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}

resource "aws_codebuild_project" "BackendCodeBuild" {
  name           = "cloudvisor-${terraform.workspace}-BackendCodeBuild"
  build_timeout  = "10"
  queued_timeout = "10"
  service_role   = aws_iam_role.CodeBuildRole.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  logs_config {
    cloudwatch_logs {
      group_name = "cloudvisor-${terraform.workspace}-build-log"
    }
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    environment_variable {
      name  = "WORKSPACE"
      value = terraform.workspace
    }
    environment_variable {
      name  = "DEPLOY_BUCKET"
      value = "cloudvisor-${terraform.workspace}-deploy"
    }
    environment_variable {
      name  = "CLUSTER_NAME"
      value = var.ecs_cluster.name
    }
    environment_variable {
      name  = "SERVICE_NAME"
      value = var.ecs_backend_service.name
    }
    environment_variable {
      name  = "BACKEND_REPOSITORY_URI"
      value = aws_ecr_repository.backend.repository_url
    }
    environment_variable {
      name  = "TASK_DEFINITION_NAME"
      value = var.ecs_backend_taskdefinition.family
    }
    environment_variable {
      name  = "DP_GROUP_NAME"
      value = aws_codedeploy_deployment_group.cloudvisor_dep.deployment_group_name
    }
    environment_variable {
      name  = "APPLICATION_NAME"
      value = aws_codedeploy_app.cloudvisor_app.name
    }
  }

  source {
    type            = "GITHUB"
    location        = var.github_repository
    git_clone_depth = 1
    buildspec       = "backend/buildspec.yml"


  }

  tags = {
    Project = "cloudvisor-${terraform.workspace}"
  }
}

resource "aws_iam_role" "cd" {
  name = "cd-${terraform.workspace}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "codedeploy.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "codedeploy-policy-attachments" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess",
    "arn:aws:iam::aws:policy/AmazonECS_FullAccess",
    "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole",
    "arn:aws:iam::aws:policy/CloudWatchFullAccess",
    "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
  ])
  role       = aws_iam_role.cd.name
  policy_arn = each.value
}

resource "aws_iam_role_policy" "s33" {
  role = aws_iam_role.cd.name

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": [
        "${aws_s3_bucket.deployment.arn}",
        "${aws_s3_bucket.deployment.arn}/*"
      ]
    }
  ]
}
POLICY
}

resource "aws_codedeploy_app" "cloudvisor_app" {
  compute_platform = "ECS"
  name             = "cloudvisor-${terraform.workspace}-app"
}

resource "aws_codedeploy_deployment_group" "cloudvisor_dep" {
  app_name               = aws_codedeploy_app.cloudvisor_app.name
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"
  deployment_group_name  = "cloudvisor-${terraform.workspace}-group"
  service_role_arn       = aws_iam_role.cd.arn

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  blue_green_deployment_config {

    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  ecs_service {
    cluster_name = var.ecs_cluster.name
    service_name = var.ecs_backend_service.name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [var.aws_backend_lb_listener.arn]
      }

      target_group {
        name = var.ecs_target_group_b.name
      }

      target_group {
        name = var.ecs_target_group_a.name
      }
    }
  }
}
