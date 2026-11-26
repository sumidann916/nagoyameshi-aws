module "alb" {
  source          = "../../modules/alb"
  name            = var.project
  vpc_id          = module.network.vpc_id
  vpc_cidr        = module.network.vpc_cidr
  subnet_ids      = module.network.public_subnet_ids
  certificate_arn = aws_acm_certificate_validation.this.certificate_arn
}
