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


resource "aws_iam_role" "BackendTaskExecutionRole" {
  assume_role_policy = jsonencode({
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
    Version = "2012-10-17"
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
  ]

  tags = {
    Project = "cloudvisor-${terraform.workspace}"
  }
}



resource "aws_codebuild_source_credential" "GithubCredentials" {
  auth_type   = "PERSONAL_ACCESS_TOKEN"
  server_type = "GITHUB"
  token       = var.github_personal_access_token
}

resource "aws_codebuild_webhook" "BackendCodeBuildWebHook" {
  project_name = aws_codebuild_project.BackendCodeBuild.name


  filter_group {
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

  filter_group {
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
      name  = "TERRAFORM_VERSION"
      value = "0.12.16"
    }
  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/metegenez/Scalable-SaaS-Infra-AWS.git"
    git_clone_depth = 1
    buildspec       = "back-end/buildspec.yml"

  }

  tags = {
    Project = "cloudvisor-${terraform.workspace}"
  }
}
