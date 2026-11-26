resource "aws_cloudwatch_metric_alarm" "rds_cpu" {
  count               = local.n
  alarm_name          = "${var.name}-rds-cpu"
  alarm_description   = "RDS の CPU 使用率が 80% 以上で 10分続いた"
  namespace           = "AWS/RDS"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 2
  threshold           = 80
  comparison_operator = "GreaterThanOrEqualToThreshold"
  alarm_actions       = local.actions
  ok_actions          = local.actions
  dimensions          = { DBInstanceIdentifier = var.db_identifier }
}

resource "aws_cloudwatch_metric_alarm" "rds_storage" {
  count               = local.n
  alarm_name          = "${var.name}-rds-free-storage"
  alarm_description   = "RDS の空き容量が 2GB 未満"
  namespace           = "AWS/RDS"
  metric_name         = "FreeStorageSpace"
  statistic           = "Minimum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 2147483648
  comparison_operator = "LessThanThreshold"
  alarm_actions       = local.actions
  ok_actions          = local.actions
  dimensions          = { DBInstanceIdentifier = var.db_identifier }
}
