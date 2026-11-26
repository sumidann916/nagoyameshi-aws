resource "aws_cloudwatch_metric_alarm" "target_5xx" {
  count               = local.n
  alarm_name          = "${var.name}-target-5xx"
  alarm_description   = "アプリが 5分間に 5回以上 5xx を返した"
  evaluation_periods  = 1
  threshold           = 5
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"
  alarm_actions       = local.actions
  ok_actions          = local.actions

  metric_query {
    id          = "total"
    expression  = "FILL(m0,0)+FILL(m1,0)"
    label       = "Target5xx"
    return_data = true
  }

  dynamic "metric_query" {
    for_each = var.target_group_arn_suffixes
    content {
      id = "m${metric_query.key}"
      metric {
        namespace   = "AWS/ApplicationELB"
        metric_name = "HTTPCode_Target_5XX_Count"
        stat        = "Sum"
        period      = 300
        dimensions = {
          LoadBalancer = var.alb_arn_suffix
          TargetGroup  = metric_query.value
        }
      }
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "unhealthy" {
  count               = local.n
  alarm_name          = "${var.name}-unhealthy-targets"
  alarm_description   = "異常なタスクが 5分以上続いている"
  evaluation_periods  = 5
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"
  alarm_actions       = local.actions
  ok_actions          = local.actions

  metric_query {
    id          = "total"
    expression  = "FILL(m0,0)+FILL(m1,0)"
    label       = "UnHealthyHostCount"
    return_data = true
  }

  dynamic "metric_query" {
    for_each = var.target_group_arn_suffixes
    content {
      id = "m${metric_query.key}"
      metric {
        namespace   = "AWS/ApplicationELB"
        metric_name = "UnHealthyHostCount"
        stat        = "Maximum"
        period      = 60
        dimensions = {
          LoadBalancer = var.alb_arn_suffix
          TargetGroup  = metric_query.value
        }
      }
    }
  }
}
