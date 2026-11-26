# ECS サービス（環境ごと）
#  - 1タスク = nginx コンテナ + PHP-FPM コンテナ（localhost:9000 で通信）
#  - ECS 標準のブルーグリーンデプロイ（ターゲットグループ blue / green を ALB ルールで切り替え）

resource "aws_ecs_service" "this" {
  name                              = var.name
  cluster                           = var.cluster_arn
  task_definition                   = aws_ecs_task_definition.app.arn
  desired_count                     = var.desired_count
  launch_type                       = "FARGATE"
  platform_version                  = "LATEST"
  health_check_grace_period_seconds = 60
  propagate_tags                    = "SERVICE"

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [var.ecs_sg_id]
    assign_public_ip = false # 要件「デプロイ用のコンテナはパブリック IP を利用してはならない」
  }

  deployment_controller {
    type = "ECS"
  }

  deployment_configuration {
    strategy             = "BLUE_GREEN"
    bake_time_in_minutes = var.bake_time_minutes
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.this["blue"].arn
    container_name   = "nginx"
    container_port   = 80

    advanced_configuration {
      alternate_target_group_arn = aws_lb_target_group.this["green"].arn
      production_listener_rule   = aws_lb_listener_rule.forward.arn
      role_arn                   = aws_iam_role.infrastructure.arn
    }
  }

  # デプロイ（CodePipeline）とブルーグリーンの切り替えで変わる項目は Terraform で戻さない
  lifecycle {
    ignore_changes = [task_definition, desired_count, load_balancer]
  }

  depends_on = [aws_iam_role_policy_attachment.infrastructure]
}
