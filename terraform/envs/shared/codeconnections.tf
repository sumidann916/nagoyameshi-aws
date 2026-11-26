# 作成直後は「保留中」。AWS コンソールの「接続」画面で GitHub と連携して承認する
resource "aws_codestarconnections_connection" "github" {
  name          = "${var.project}-github"
  provider_type = "GitHub"
}
