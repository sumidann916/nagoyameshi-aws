variable "name" {
  description = "例: nagoyameshi-prod"
  type        = string
}

variable "region" {
  type = string
}

variable "account_id" {
  type = string
}

variable "cluster_arn" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  description = "private-app サブネット（パブリック IP は付けない）"
  type        = list(string)
}

variable "ecs_sg_id" {
  type = string
}

# --- ALB ---
variable "https_listener_arn" {
  type = string
}

variable "host_name" {
  description = "本番は APEX（例: example.com）、検証はサブドメイン（例: stg.example.com）"
  type        = string
}

# --- task ---
variable "app_image" {
  description = "PHP-FPM（Laravel）イメージ"
  type        = string
}

variable "nginx_image" {
  type = string
}

variable "cpu" {
  type    = number
  default = 256
}

variable "memory" {
  type    = number
  default = 512
}

variable "environment" {
  description = "コンテナに直接渡す固定値の環境変数"
  type        = map(string)
}

variable "secret_names" {
  description = "SSM Parameter Store から注入する変数名（パラメータは ssm_path/<名前>）"
  type        = list(string)
}

variable "ssm_path" {
  description = "例: /nagoyameshi/prod"
  type        = string
}

variable "images_bucket_arn" {
  type = string
}

variable "images_prefix" {
  description = "このタスクが操作できる画像の接頭辞（prod / stg）"
  type        = string
}

variable "log_retention_days" {
  type = number
}

# --- service / scaling ---
variable "desired_count" {
  type = number
}

variable "min_count" {
  type = number
}

variable "max_count" {
  type = number
}

variable "cpu_target" {
  type    = number
  default = 70
}

variable "bake_time_minutes" {
  description = "ブルーグリーンで切り替えた後、旧タスク（Blue）を残しておく時間"
  type        = number
  default     = 10
}
