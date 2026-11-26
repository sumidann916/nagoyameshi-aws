resource "aws_ecr_repository" "this" {
  for_each             = toset(["app", "nginx"])
  name                 = "${var.project}-${each.key}"
  image_tag_mutability = "MUTABLE" # 環境のタグ（prod / stg）をビルドのたびに付け替えるため
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "this" {
  for_each   = aws_ecr_repository.this
  repository = each.value.name
  policy = jsonencode({
    rules = [
      {
        # prod / stg タグの付いたイメージ（今動いている版）を下のルールで消さないためのルール
        rulePriority = 1
        description  = "環境タグの付いたイメージは消さない"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["prod", "stg"]
          countType     = "imageCountMoreThan"
          countNumber   = 100
        }
        action = { type = "expire" }
      },
      {
        rulePriority = 2
        description  = "それ以外は直近 20 個（2環境 × 10）を残す（ロールバック用）"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 20
        }
        action = { type = "expire" }
      }
    ]
  })
}
