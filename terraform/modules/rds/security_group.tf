resource "aws_security_group" "rds" {
  name        = "${var.name}-rds"
  description = "RDS ${var.name}"
  vpc_id      = var.vpc_id
  tags        = { Name = "${var.name}-rds" }
}

resource "aws_vpc_security_group_ingress_rule" "mysql" {
  security_group_id            = aws_security_group.rds.id
  description                  = "MySQL from ECS tasks of the same environment only"
  referenced_security_group_id = var.app_sg_id
  ip_protocol                  = "tcp"
  from_port                    = 3306
  to_port                      = 3306
}
