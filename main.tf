locals {
  region_name       = data.aws_region.current.name
  availability_zone = data.aws_availability_zones.available.names[0]
}

data "aws_region" "current" {}
data "aws_availability_zones" "available" {
  state = "available"
}

module "ipam" {
  source             = "./modules/ipam"
  region_name        = local.region_name
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
  availability_zone  = local.availability_zone
  ipam_pool_id       = module.ipam.infrastructure_pool_id
  toplevel_pool_cidr = module.ipam.toplevel_pool_cidr
  transit_gateway_id = module.transit_gateway.transit_gateway_id
  domain_name        = var.domain_name
}

module "vpc_endpoint" {
  source             = "./modules/vpce_aggregation"
  system_id          = var.system_id
  region_name        = local.region_name
  availability_zone  = local.availability_zone
  ipam_pool_id       = module.ipam.infrastructure_pool_id
  toplevel_pool_cidr = module.ipam.toplevel_pool_cidr
  transit_gateway_id = module.transit_gateway.transit_gateway_id
  dns_vpc_id         = module.dns.vpc_id
  service_codes = [
    "ssm",
    "ssmmessages",
    "ec2messages",
  ]
}

module "common_iam" {
  source    = "./modules/common_iam"
  system_id = var.system_id
}

module "workloads" {
  count = 2

  source                   = "./modules/workload"
  system_id                = var.system_id
  workload_index           = count.index
  region_name              = local.region_name
  availability_zone        = local.availability_zone
  ipam_pool_id             = module.ipam.workload_pool_id
  toplevel_pool_cidr       = module.ipam.toplevel_pool_cidr
  transit_gateway_id       = module.transit_gateway.transit_gateway_id
  instance_profile_name    = module.common_iam.common_instance_profile_name
  route53_zone_id          = module.dns.zone_id
  parent_domain_name       = module.dns.domain_name
  primary_dns_ip_address   = module.dns.primary_dns_ip_address
  secondary_dns_ip_address = module.dns.secondary_dns_ip_address
}