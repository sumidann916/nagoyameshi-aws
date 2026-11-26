output "url" {
  value = "https://${local.host_name}"
}

output "ssm_parameters_to_register_manually" {
  description = "AWS コンソールまたは CLI で SecureString として登録が必要なパラメータ"
  value       = [for n in local.manual_secrets : "${local.ssm_path}/${n}"]
}

output "pipeline_name" {
  value = module.cicd.pipeline_name
}

output "ecs_service_name" {
  value = module.ecs.service_name
}

output "migration_task_family" {
  value = module.ecs.migration_task_family
}

output "ecs_security_group_id" {
  value = aws_security_group.ecs.id
}
