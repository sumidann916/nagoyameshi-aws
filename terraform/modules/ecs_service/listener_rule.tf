# 本番トラフィックのルール（ALB は環境ごとなので 1つだけ）。転送先の重み（blue/green）は ECS がデプロイ時に書き換える
resource "aws_lb_listener_rule" "forward" {
  listener_arn = var.https_listener_arn
  priority     = 10

  action {
    type = "forward"
    forward {
      target_group {
        arn    = aws_lb_target_group.this["blue"].arn
        weight = 100
      }
      target_group {
        arn    = aws_lb_target_group.this["green"].arn
        weight = 0
      }
    }
  }

  condition {
    host_header {
      values = [var.host_name]
    }
  }

  lifecycle {
    ignore_changes = [action]
  }
}
