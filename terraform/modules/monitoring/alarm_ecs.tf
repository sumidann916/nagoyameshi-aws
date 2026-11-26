resource "aws_cloudwatch_metric_alarm" "ecs" {
  for_each            = var.full ? toset(["CPUUtilization", "MemoryUtilization"]) : toset([])
  alarm_name          = "${var.name}-ecs-${lower(each.key)}"
  alarm_description   = "ECS の ${each.key} が 80% 以上で 10分続いた"
  namespace           = "AWS/ECS"
  metric_name         = each.key
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 2
  threshold           = 80
  comparison_operator = "GreaterThanOrEqualToThreshold"
  alarm_actions       = local.actions
  ok_actions          = local.actions
  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = var.service_name
  }
}
