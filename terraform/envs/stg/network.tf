module "network" {
  source     = "../../modules/network"
  name       = local.name
  region     = var.region
  cidr_block = var.vpc_cidr
}
