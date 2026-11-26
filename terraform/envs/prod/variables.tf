variable "region" {
  type    = string
  default = "ap-northeast-1"
}

variable "project" {
  type    = string
  default = "nagoyameshi"
}

variable "env" {
  description = "prod または stg"
  type        = string
  validation {
    condition     = contains(["prod", "stg"], var.env)
    error_message = "env は prod か stg を指定する。"
  }
}

variable "tfstate_bucket" {
  description = "bootstrap で作成した State 用バケット名（shared の State を読むため）"
  type        = string
}

# --- ドメイン・アクセス ---
variable "subdomain" {
  description = "空なら APEX（本番）。検証は \"stg\""
  type        = string
}

variable "allowed_cidrs" {
  description = "空なら誰でもアクセス可。検証は社内の IP（例: [\"203.0.113.10/32\"]）"
  type        = list(string)
  default     = []
}

variable "rule_priority" {
  description = "ALB リスナールールの優先度（検証 10、本番 30。検証の 403 ルールは +10 の 20）"
  type        = number
}

# --- アプリ ---
variable "app_env" {
  description = "Laravel の APP_ENV"
  type        = string
}

variable "filesystem_disk" {
  description = "画像の保存先。S3 対応のコード変更（設計書の課題 5）が済むまでは local のまま"
  type        = string
  default     = "local"
}

variable "mail_from_address" {
  description = "SES で検証済みの送信元アドレス"
  type        = string
}

# --- 台数 ---
variable "min_count" {
  type = number
}

variable "max_count" {
  type = number
}

# --- RDS ---
variable "db_multi_az" {
  type = bool
}

variable "db_deletion_protection" {
  type = bool
}

variable "db_final_snapshot" {
  type = bool
}

# --- 監視・ログ ---
variable "full_monitoring" {
  description = "true: 全アラーム（本番）、false: ログの ERROR のみ（検証）"
  type        = bool
}

variable "log_retention_days" {
  type = number
}

# --- CI/CD ---
variable "github_owner" {
  type = string
}

variable "github_repo" {
  type = string
}

variable "github_branch" {
  type = string
}

variable "require_approval" {
  description = "デプロイ前に手動承認を挟むか"
  type        = bool
  default     = false
}
