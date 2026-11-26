locals {
  restricted   = length(var.allowed_cidrs) > 0
  ssm_arn_base = "arn:aws:ssm:${var.region}:${var.account_id}:parameter${var.ssm_path}"

  log_config = {
    for c in ["app", "nginx", "migration"] : c => {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.this[c].name
        awslogs-region        = var.region
        awslogs-stream-prefix = c
      }
    }
  }

  app_container = {
    name        = "app"
    image       = var.app_image
    essential   = true
    environment = [for k, v in var.environment : { name = k, value = v }]
    secrets     = [for n in var.secret_names : { name = n, valueFrom = "${local.ssm_arn_base}/${n}" }]
  }
}
