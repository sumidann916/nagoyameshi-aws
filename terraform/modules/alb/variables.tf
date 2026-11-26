variable "name" {
  description = "例: nagoyameshi-prod"
  type        = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  description = "public サブネット"
  type        = list(string)
}

variable "certificate_arn" {
  type = string
}

variable "allowed_cidrs" {
  description = "空なら誰でもアクセス可（本番）。検証は社内の IP（例: [\"203.0.113.10/32\"]）"
  type        = list(string)
  default     = []
}

variable "target_sg_id" {
  description = "転送先（ECS タスク）のセキュリティグループ"
  type        = string
}
