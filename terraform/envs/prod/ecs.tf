module "ecs" {
  source     = "../../modules/ecs_service"
  name       = local.name
  region     = var.region
  account_id = local.account_id

  cluster_arn = local.s.ecs_cluster_arn
  vpc_id      = module.network.vpc_id
  subnet_ids  = module.network.app_subnet_ids
  ecs_sg_id   = aws_security_group.ecs.id

  https_listener_arn = module.alb.https_listener_arn
  host_name          = local.host_name

  # 最初は環境のタグ（prod / stg）。デプロイ後はコミット ID のタグに置き換わる
  app_image   = "${local.s.ecr_repository_urls["app"]}:${var.env}"
  nginx_image = "${local.s.ecr_repository_urls["nginx"]}:${var.env}"

  ssm_path     = local.ssm_path
  secret_names = concat(local.manual_secrets, keys(local.managed_params))
  environment = {
    APP_NAME           = "NAGOYAMESHI"
    APP_ENV            = var.app_env
    APP_DEBUG          = "false"
    LOG_CHANNEL        = "stderr"
    DB_CONNECTION      = "mysql"
    DB_PORT            = "3306"
    FILESYSTEM_DISK    = var.filesystem_disk
    AWS_DEFAULT_REGION = var.region
    MAIL_MAILER        = "smtp"
    MAIL_HOST          = "email-smtp.${var.region}.amazonaws.com"
    MAIL_PORT          = "587"
    MAIL_ENCRYPTION    = "tls"
    MAIL_FROM_ADDRESS  = var.mail_from_address
    SESSION_DRIVER     = "cookie" # 複数タスクでもログイン状態を保つ（設計書の課題 2）
  }

  images_bucket_arn  = local.s.images_bucket_arn
  images_prefix      = var.env
  log_retention_days = var.log_retention_days

  desired_count = var.min_count
  min_count     = var.min_count
  max_count     = var.max_count

  depends_on = [aws_ssm_parameter.managed]
}
