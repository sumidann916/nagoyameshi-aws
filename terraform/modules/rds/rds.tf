# RDS for MySQL 8.4（環境ごと）
#  - 本番：Multi-AZ・削除保護あり　検証：Single-AZ
#  - 自動バックアップ 7日（要件「バックアップは 1週間保持」）

resource "aws_db_subnet_group" "this" {
  name       = var.name
  subnet_ids = var.subnet_ids
}

resource "aws_db_parameter_group" "this" {
  name   = "${var.name}-mysql84"
  family = "mysql8.4"

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }
  parameter {
    name  = "collation_server"
    value = "utf8mb4_unicode_ci"
  }
  parameter {
    name  = "time_zone"
    value = "Asia/Tokyo"
  }
}

# パスワードは State に残る（設計書「Terraform と State 管理」）。State バケットは作業者のみ読める設定にする
resource "random_password" "db" {
  length  = 24
  special = false
}

resource "aws_db_instance" "this" {
  identifier     = var.name
  engine         = "mysql"
  engine_version = "8.4"
  instance_class = var.instance_class

  storage_type           = "gp3"
  allocated_storage      = var.allocated_storage
  storage_encrypted      = true
  multi_az               = var.multi_az
  db_subnet_group_name   = aws_db_subnet_group.this.name
  parameter_group_name   = aws_db_parameter_group.this.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = false

  db_name  = var.db_name
  username = var.username
  password = random_password.db.result

  backup_retention_period    = var.backup_retention_days
  backup_window              = "18:00-19:00" # 日本時間 03:00〜04:00
  maintenance_window         = "sun:19:30-sun:20:30"
  copy_tags_to_snapshot      = true
  auto_minor_version_upgrade = true
  deletion_protection        = var.deletion_protection
  skip_final_snapshot        = !var.final_snapshot
  final_snapshot_identifier  = var.final_snapshot ? "${var.name}-final" : null
}
