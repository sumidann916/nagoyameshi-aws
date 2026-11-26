module "monitoring" {
  source                    = "../../modules/monitoring"
  name                      = local.name
  full                      = var.full_monitoring
  sns_topic_arn             = local.s.sns_topic_arn
  app_log_group_name        = module.ecs.app_log_group_name
  alb_arn_suffix            = module.alb.alb_arn_suffix
  target_group_arn_suffixes = module.ecs.target_group_arn_suffixes
  cluster_name              = local.s.ecs_cluster_name
  service_name              = module.ecs.service_name
  db_identifier             = module.rds.identifier
}
