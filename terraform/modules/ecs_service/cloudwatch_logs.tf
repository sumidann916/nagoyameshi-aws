resource "aws_cloudwatch_log_group" "this" {
  for_each          = toset(["app", "nginx", "migration"])
  name              = "/ecs/${var.name}/${each.key}"
  retention_in_days = var.log_retention_days
}
