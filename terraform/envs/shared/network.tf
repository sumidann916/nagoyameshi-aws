module "network" {
  source = "../../modules/network"
  name   = var.project
  region = var.region
}
