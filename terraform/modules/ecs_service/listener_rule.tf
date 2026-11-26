# 本番トラフィックのルール。転送先の重み（blue/green）は ECS がデプロイ時に書き換える
resource "aws_lb_listener_rule" "forward" {
  listener_arn = var.https_listener_arn
  priority     = var.rule_priority

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

  dynamic "condition" {
    for_each = local.restricted ? [1] : []
    content {
      source_ip {
        values = var.allowed_cidrs
      }
    }
  }

  lifecycle {
    ignore_changes = [action]
  }
}

# 検証サイト：許可 IP 以外は 403
resource "aws_lb_listener_rule" "deny" {
  count        = local.restricted ? 1 : 0
  listener_arn = var.https_listener_arn
  priority     = var.rule_priority + 10

  action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Forbidden"
      status_code  = "403"
    }
  }

  condition {
    host_header {
      values = [var.host_name]
    }
  }
}
