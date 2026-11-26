resource "aws_cloudwatch_log_group" "build" {
  name              = "/codebuild/${var.name}"
  retention_in_days = var.log_retention_days
}

resource "aws_iam_role" "codebuild" {
  name = "${var.name}-codebuild"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Principal = { Service = "codebuild.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "codebuild" {
  name = "codebuild"
  role = aws_iam_role.codebuild.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = "${aws_cloudwatch_log_group.build.arn}:*"
      },
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:GetObjectVersion", "s3:PutObject"]
        Resource = "${local.artifact_arn}/*"
      },
      {
        Effect   = "Allow"
        Action   = ["ecr:GetAuthorizationToken"]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability", "ecr:BatchGetImage", "ecr:GetDownloadUrlForLayer",
          "ecr:InitiateLayerUpload", "ecr:UploadLayerPart", "ecr:CompleteLayerUpload", "ecr:PutImage"
        ]
        Resource = [var.app_repository_arn, var.nginx_repository_arn]
      },
      {
        Effect   = "Allow"
        Action   = ["ecs:RunTask"]
        Resource = "arn:aws:ecs:${var.region}:${var.account_id}:task-definition/${var.migration_task_family}:*"
      },
      {
        Effect   = "Allow"
        Action   = ["ecs:DescribeTasks"]
        Resource = "*"
      },
      {
        Effect    = "Allow"
        Action    = ["iam:PassRole"]
        Resource  = var.pass_role_arns
        Condition = { StringEquals = { "iam:PassedToService" = "ecs-tasks.amazonaws.com" } }
      }
    ]
  })
}

resource "aws_codebuild_project" "this" {
  name          = var.name
  service_role  = aws_iam_role.codebuild.arn
  build_timeout = 30

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    type            = "LINUX_CONTAINER"
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    privileged_mode = true # docker build に必要

    # 既存の buildspec.yml が参照する変数
    environment_variable {
      name  = "REPOSITORY_URI"
      value = var.app_repository_url
    }
    environment_variable {
      name  = "CONTAINER_NAME"
      value = "app"
    }
    environment_variable {
      name  = "ECS_CLUSTER_NAME"
      value = var.cluster_name
    }
    environment_variable {
      name  = "MIGRATION_TASK_DEFINITION"
      value = var.migration_task_family
    }
    environment_variable {
      name  = "SUBNET_ID_1"
      value = var.subnet_ids[0]
    }
    environment_variable {
      name  = "SUBNET_ID_2"
      value = var.subnet_ids[1]
    }
    environment_variable {
      name  = "SECURITY_GROUP_ID"
      value = var.ecs_sg_id
    }
    environment_variable {
      name  = "ENV_TAG"
      value = var.env_tag
    }
    environment_variable {
      name  = "NGINX_REPOSITORY_URI"
      value = var.nginx_repository_url
    }
    environment_variable {
      name  = "NGINX_CONTAINER_NAME"
      value = "nginx"
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name = aws_cloudwatch_log_group.build.name
    }
  }
}
