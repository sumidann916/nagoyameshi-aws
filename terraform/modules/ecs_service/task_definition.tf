resource "aws_ecs_task_definition" "app" {
  family                   = var.name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = aws_iam_role.execution.arn
  task_role_arn            = aws_iam_role.task.arn

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  # アップロード画像（storage/app/public）を nginx と共有するタスク内のボリューム
  # S3 保存に切り替えるまでのつなぎ。タスクが入れ替わると中身は消える（設計書の課題 5）
  volume {
    name = "storage-public"
  }

  container_definitions = jsonencode([
    merge(local.app_container, {
      portMappings     = [{ containerPort = 9000, protocol = "tcp" }]
      mountPoints      = [{ sourceVolume = "storage-public", containerPath = "/var/www/html/storage/app/public", readOnly = false }]
      logConfiguration = local.log_config["app"]
    }),
    {
      name             = "nginx"
      image            = var.nginx_image
      essential        = true
      portMappings     = [{ containerPort = 80, protocol = "tcp" }]
      mountPoints      = [{ sourceVolume = "storage-public", containerPath = "/var/www/html/public/storage", readOnly = true }]
      dependsOn        = [{ containerName = "app", condition = "START" }]
      logConfiguration = local.log_config["nginx"]
    }
  ])
}

# マイグレーション用（buildspec.yml の run-task で起動）。nginx は不要
resource "aws_ecs_task_definition" "migration" {
  family                   = "${var.name}-migrate"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = aws_iam_role.execution.arn
  task_role_arn            = aws_iam_role.task.arn

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  container_definitions = jsonencode([
    merge(local.app_container, {
      command          = ["php", "artisan", "migrate", "--force"]
      logConfiguration = local.log_config["migration"]
    })
  ])
}
