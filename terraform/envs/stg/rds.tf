module "rds" {
  source              = "../../modules/rds"
  name                = local.name
  vpc_id              = local.s.vpc_id
  subnet_ids          = local.s.db_subnet_ids
  app_sg_id           = aws_security_group.ecs.id
  multi_az            = var.db_multi_az
  deletion_protection = var.db_deletion_protection
  final_snapshot      = var.db_final_snapshot
}
