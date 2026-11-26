variable "name" {
  type = string
}

variable "full" {
  type = bool
}

variable "sns_topic_arn" {
  type = string
}

variable "app_log_group_name" {
  type = string
}

variable "alb_arn_suffix" {
  type = string
}

variable "target_group_arn_suffixes" {
  description = "blue と green の 2つ（どちらが本番かはデプロイごとに入れ替わるため合計で見る）"
  type        = list(string)
}

variable "cluster_name" {
  type = string
}

variable "service_name" {
  type = string
}

variable "db_identifier" {
  type = string
}
