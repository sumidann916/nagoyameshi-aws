resource "aws_security_group" "ecs" {
  name        = "${local.name}-ecs"
  description = "ECS tasks ${local.name}"
  vpc_id      = module.network.vpc_id
  tags        = { Name = "${local.name}-ecs" }
}

resource "aws_vpc_security_group_ingress_rule" "ecs_from_alb" {
  security_group_id            = aws_security_group.ecs.id
  description                  = "HTTP from ALB only"
  referenced_security_group_id = module.alb.alb_sg_id
  ip_protocol                  = "tcp"
  from_port                    = 80
  to_port                      = 80
}

resource "aws_vpc_security_group_egress_rule" "ecs_to_rds" {
  security_group_id            = aws_security_group.ecs.id
  description                  = "MySQL to RDS of the same environment"
  referenced_security_group_id = module.rds.security_group_id
  ip_protocol                  = "tcp"
  from_port                    = 3306
  to_port                      = 3306
}

resource "aws_vpc_security_group_egress_rule" "ecs_https" {
  security_group_id = aws_security_group.ecs.id
  description       = "HTTPS via NAT (ECR, SSM, Logs, Stripe) and S3 endpoint"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "ecs_smtp" {
  security_group_id = aws_security_group.ecs.id
  description       = "SMTP (SES) via NAT"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 587
  to_port           = 587
}
