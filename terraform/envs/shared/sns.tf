resource "aws_sns_topic" "alarm" {
  name = "${var.project}-alarm"
}

# 作成後に届く確認メールのリンクを押すと有効になる
resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alarm.arn
  protocol  = "email"
  endpoint  = var.alarm_email
}
