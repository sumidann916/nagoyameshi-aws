resource "aws_cloudwatch_log_metric_filter" "app_error" {
  name           = "${var.name}-app-error"
  log_group_name = var.app_log_group_name
  pattern        = "ERROR"

  metric_transformation {
    name          = "AppErrorCount"
    namespace     = "Nagoyameshi/${var.name}"
    value         = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_metric_alarm" "app_error" {
  alarm_name          = "${var.name}-app-error"
  alarm_description   = "Laravel のログに ERROR が出力された"
  namespace           = "Nagoyameshi/${var.name}"
  metric_name         = "AppErrorCount"
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"
  alarm_actions       = local.actions
  ok_actions          = local.actions
  depends_on          = [aws_cloudwatch_log_metric_filter.app_error]
}
