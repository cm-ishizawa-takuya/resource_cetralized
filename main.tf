data "aws_region" "current" {}
data "aws_availability_zones" "available" {
  state = "available"
}

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

module "dns" {
  source             = "./modules/dns_aggregation"
  system_id          = var.system_id
  availability_zone  = data.aws_availability_zones.available.names[0]
  ipam_pool_id       = module.ipam.infrastructure_pool_id
  toplevel_pool_cidr = module.ipam.toplevel_pool_cidr
  transit_gateway_id = module.transit_gateway.transit_gateway_id
  domain_name        = var.domain_name
}