data "aws_region" "current" {}

module "ipam" {
  source             = "./modules/ipam"
  region_name        = data.aws_region.current.name
  system_id          = var.system_id
  toplevel_pool_cidr = var.ipam_topleve_pool_cidr
}

module "transit_gateway" {
  source    = "./modules/transit_gateway"
  system_id = var.system_id
}