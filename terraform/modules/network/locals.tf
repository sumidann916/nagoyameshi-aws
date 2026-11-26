# サブネットは VPC の CIDR から決める（10.X.0.0/16 なら public 10.X.1・2、private-app 10.X.11・12、private-db 10.X.21・22）
locals {
  public_cidrs = [for i in [1, 2] : cidrsubnet(var.cidr_block, 8, i)]
  app_cidrs    = [for i in [11, 12] : cidrsubnet(var.cidr_block, 8, i)]
  db_cidrs     = [for i in [21, 22] : cidrsubnet(var.cidr_block, 8, i)]
}
