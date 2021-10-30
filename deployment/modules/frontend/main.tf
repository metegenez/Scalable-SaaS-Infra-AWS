data "aws_secretsmanager_secret" "by-arn" {
  arn = "arn:aws:secretsmanager:us-east-1:714130184239:secret:rdsclustersecrets-Gm7kwP"
}

data "aws_secretsmanager_secret_version" "secret" {
  secret_id = data.aws_secretsmanager_secret.by-arn.id
}


resource "aws_route53_record" "front" {
  zone_id = "Z08633611HETQYXOEWMJ4"
  name    = "visor-${terraform.workspace}.metawise.co"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.website_cdn.domain_name
    zone_id                = aws_cloudfront_distribution.website_cdn.hosted_zone_id
    evaluate_target_health = true
  }
}



resource "aws_codebuild_project" "FrontCodeBuild" {
  name           = "cloudvisor-${terraform.workspace}-FrontCodeBuild"
  build_timeout  = "10"
  queued_timeout = "10"
  service_role   = aws_iam_role.FrontCodeBuildRole.arn

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
      value = "cloudvisor-${terraform.workspace}-frontend"
    }
  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/metegenez/Scalable-SaaS-Infra-AWS.git"
    git_clone_depth = 1
    buildspec       = "frontend/buildspec.yml"


  }

  tags = {
    Project = "cloudvisor-${terraform.workspace}"
  }
}

resource "aws_iam_role" "FrontCodeBuildRole" {
  name               = "cloudvisor-FrontCodeBuildRole-${terraform.workspace}"
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
resource "aws_iam_role_policy_attachment" "f-codebuild-policy-attachments" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AWSCodeBuildAdminAccess",
    "arn:aws:iam::aws:policy/CloudWatchFullAccess",
    "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
  ])
  role       = aws_iam_role.FrontCodeBuildRole.name
  policy_arn = each.value
}
resource "aws_iam_role_policy" "f_s3" {
  role = aws_iam_role.FrontCodeBuildRole.name

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
        "${aws_s3_bucket.deploy_bucket.arn}",
        "${aws_s3_bucket.deploy_bucket.arn}/*"
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

resource "aws_codebuild_webhook" "FrontCodeBuildWebHook" {
  project_name = aws_codebuild_project.FrontCodeBuild.name

  dynamic "filter_group" {
    for_each = terraform.workspace == "dev" ? ["1"] : []
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
        pattern = "frontend/*"
      }
    }
  }

  dynamic "filter_group" {
    for_each = terraform.workspace != "dev" ? ["1"] : []
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
        pattern = "frontend/*"
      }
    }
  }


}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.deploy_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.deploy_bucket.arn}/*"
      },
    ]
  })
}

resource "aws_s3_bucket" "deploy_bucket" {
  bucket = "cloudvisor-${terraform.workspace}-frontend"
  acl    = "public-read"

  website {
    index_document = "index.html"
    error_document = "index.html"
  }
  tags = {
    Project = "cloudvisor-${terraform.workspace}"
  }
}

resource "aws_cloudfront_origin_access_identity" "cloudfront_oia" {
  comment = "example origin access identify"
}

resource "aws_cloudfront_distribution" "website_cdn" {
  enabled = true

  origin {
    origin_id   = "origin-bucket-${aws_s3_bucket.deploy_bucket.id}"
    domain_name = aws_s3_bucket.deploy_bucket.website_endpoint

    custom_origin_config {
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  default_root_object = "index.html"

  aliases = ["visor-${terraform.workspace}.metawise.co"]

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "DELETE", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    min_ttl                = "0"
    default_ttl            = "300"
    max_ttl                = "1200"
    target_origin_id       = "origin-bucket-${aws_s3_bucket.deploy_bucket.id}"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    ssl_support_method  = "sni-only"
    acm_certificate_arn = "arn:aws:acm:us-east-1:714130184239:certificate/6bcf0578-892d-441b-9eee-1be9ad1fd9d7"
  }

  tags = {
    Project = "cloudvisor-${terraform.workspace}"
  }
}


