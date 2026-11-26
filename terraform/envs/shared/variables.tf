variable "region" {
  type    = string
  default = "ap-northeast-1"
}

variable "project" {
  type    = string
  default = "nagoyameshi"
}

variable "domain_name" {
  description = "本番の APEX ドメイン（例: example.com）。検証は stg.<domain_name>"
  type        = string
}

variable "alarm_email" {
  description = "アラームと請求アラートの通知先メールアドレス"
  type        = string
}

variable "monthly_budget_usd" {
  description = "AWS Budgets の月額上限（USD）。80% を超えるとメール通知"
  type        = number
  default     = 350
}
