variable "name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "app_sg_id" {
  description = "3306 への接続を許可する ECS タスクの SG"
  type        = string
}

variable "instance_class" {
  type    = string
  default = "db.t4g.micro"
}

variable "allocated_storage" {
  type    = number
  default = 20
}

variable "multi_az" {
  type = bool
}

variable "deletion_protection" {
  type = bool
}

variable "final_snapshot" {
  description = "削除時に最終スナップショットを残すか"
  type        = bool
}

variable "backup_retention_days" {
  type    = number
  default = 7
}

variable "db_name" {
  type    = string
  default = "laravel_nagoyameshi"
}

variable "username" {
  type    = string
  default = "nagoyameshi"
}
