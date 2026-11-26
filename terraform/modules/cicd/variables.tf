variable "name" {
  type = string
}

variable "region" {
  type = string
}

variable "account_id" {
  type = string
}

variable "connection_arn" {
  description = "CodeConnections（GitHub）。作成後にコンソールで「接続を更新」して承認が必要"
  type        = string
}

variable "github_owner" {
  type = string
}

variable "github_repo" {
  type = string
}

variable "github_branch" {
  type = string
}

variable "artifact_bucket" {
  type = string
}

variable "app_repository_url" {
  type = string
}

variable "app_repository_arn" {
  type = string
}

variable "nginx_repository_url" {
  type = string
}

variable "nginx_repository_arn" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "service_name" {
  type = string
}

variable "migration_task_family" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "ecs_sg_id" {
  type = string
}

variable "pass_role_arns" {
  description = "タスク実行ロールとタスクロール"
  type        = list(string)
}

variable "env_tag" {
  description = "環境のイメージタグ（prod / stg）。buildspec が push し、タスク定義が参照する"
  type        = string
}

variable "require_approval" {
  type    = bool
  default = false
}

variable "log_retention_days" {
  type = number
}
