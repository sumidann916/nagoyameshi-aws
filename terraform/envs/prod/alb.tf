module "alb" {
  source          = "../../modules/alb"
  name            = local.name
  vpc_id          = module.network.vpc_id
  subnet_ids      = module.network.public_subnet_ids
  certificate_arn = local.s.certificate_arn
  allowed_cidrs   = var.allowed_cidrs
  target_sg_id    = aws_security_group.ecs.id
}
