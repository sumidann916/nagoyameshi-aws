resource "aws_ecs_cluster" "this" {
  name = var.project

  setting {
    name  = "containerInsights"
    value = "disabled" # 有料のため学習用ではオフ
  }
}
