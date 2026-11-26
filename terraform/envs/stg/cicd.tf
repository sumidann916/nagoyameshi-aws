module "cicd" {
  source     = "../../modules/cicd"
  name       = local.name
  region     = var.region
  account_id = local.account_id

  connection_arn = local.s.github_connection_arn
  github_owner   = var.github_owner
  github_repo    = var.github_repo
  github_branch  = var.github_branch

  artifact_bucket      = local.s.artifact_bucket
  app_repository_url   = local.s.ecr_repository_urls["app"]
  app_repository_arn   = local.s.ecr_repository_arns["app"]
  nginx_repository_url = local.s.ecr_repository_urls["nginx"]
  nginx_repository_arn = local.s.ecr_repository_arns["nginx"]

  cluster_name          = local.s.ecs_cluster_name
  service_name          = module.ecs.service_name
  migration_task_family = module.ecs.migration_task_family
  subnet_ids            = local.s.app_subnet_ids
  ecs_sg_id             = aws_security_group.ecs.id
  pass_role_arns        = [module.ecs.execution_role_arn, module.ecs.task_role_arn]

  env_tag            = var.env
  require_approval   = var.require_approval
  log_retention_days = var.log_retention_days
}
