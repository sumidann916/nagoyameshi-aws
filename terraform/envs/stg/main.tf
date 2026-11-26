# 環境（本番・検証）ごとのリソースで共通に使う参照と値
# envs/prod と envs/stg の *.tf（backend.tf 以外）は同じ内容。違いは backend.tf の key と terraform.tfvars の値だけ

data "aws_caller_identity" "current" {}

data "terraform_remote_state" "shared" {
  backend = "s3"
  config = {
    bucket = var.tfstate_bucket
    key    = "shared/terraform.tfstate"
    region = var.region
  }
}

locals {
  s          = data.terraform_remote_state.shared.outputs
  name       = "${var.project}-${var.env}"
  account_id = data.aws_caller_identity.current.account_id
  host_name  = var.subdomain == "" ? local.s.domain_name : "${var.subdomain}.${local.s.domain_name}"
  ssm_path   = "/${var.project}/${var.env}"

  # SSM に手動で登録する秘密情報（Terraform では値を扱わない）
  manual_secrets = ["APP_KEY", "STRIPE_KEY", "STRIPE_SECRET", "MAIL_USERNAME", "MAIL_PASSWORD"]

  # Terraform が値を登録するパラメータ
  managed_params = {
    DB_HOST     = { type = "String", value = module.rds.address }
    DB_DATABASE = { type = "String", value = module.rds.db_name }
    DB_USERNAME = { type = "String", value = module.rds.username }
    DB_PASSWORD = { type = "SecureString", value = module.rds.password }
    AWS_BUCKET  = { type = "String", value = local.s.images_bucket }
    AWS_URL     = { type = "String", value = "https://${local.s.images_cdn_domain}" }
    APP_URL     = { type = "String", value = "https://${local.host_name}" }
  }
}
