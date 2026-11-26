output "service_name" {
  value = aws_ecs_service.this.name
}

output "migration_task_family" {
  value = aws_ecs_task_definition.migration.family
}

output "execution_role_arn" {
  value = aws_iam_role.execution.arn
}

output "task_role_arn" {
  value = aws_iam_role.task.arn
}

output "target_group_arn_suffixes" {
  value = [for tg in aws_lb_target_group.this : tg.arn_suffix]
}

output "app_log_group_name" {
  value = aws_cloudwatch_log_group.this["app"].name
}
