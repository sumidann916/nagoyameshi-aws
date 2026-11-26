locals {
  # allowed_cidrs が空なら誰でも（本番）、指定があればその IP だけ（検証）
  source_cidrs = length(var.allowed_cidrs) == 0 ? ["0.0.0.0/0"] : var.allowed_cidrs
}

resource "aws_security_group" "alb" {
  name        = "${var.name}-alb"
  description = "ALB ${var.name}"
  vpc_id      = var.vpc_id
  tags        = { Name = "${var.name}-alb" }
}

resource "aws_vpc_security_group_ingress_rule" "https" {
  for_each          = toset(local.source_cidrs)
  security_group_id = aws_security_group.alb.id
  description       = "HTTPS from ${each.key == "0.0.0.0/0" ? "internet" : "allowed IP"}"
  cidr_ipv4         = each.key
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  for_each          = toset(local.source_cidrs)
  security_group_id = aws_security_group.alb.id
  description       = "HTTP (redirect to HTTPS only)"
  cidr_ipv4         = each.key
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "to_tasks" {
  security_group_id            = aws_security_group.alb.id
  description                  = "HTTP to ECS tasks (nginx)"
  referenced_security_group_id = var.target_sg_id
  ip_protocol                  = "tcp"
  from_port                    = 80
  to_port                      = 80
}
