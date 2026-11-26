# CloudWatch アラーム → SNS → メール（要件「一般的な監視項目を設定し、エラーが出ればメールで通知」）
#  - 全環境：Laravel ログの ERROR
#  - full = true（本番）：ALB 5xx・異常ターゲット・ECS CPU/メモリ・RDS CPU/空き容量

locals {
  actions = [var.sns_topic_arn]
  n       = var.full ? 1 : 0
}
