output "toplevel_pool_id" {
  value = aws_vpc_ipam_pool.toplevel.id
}

output "toplevel_pool_cidr" {
  value = var.toplevel_pool_cidr
}

output "infrastructure_pool_id" {
  value = aws_vpc_ipam_pool.infrastructure.id
}

output "infrastructure_pool_cidr" {
  value = local.infrastructure_pool_cidr
}

output "workload_pool_id" {
  value = aws_vpc_ipam_pool.workload.id
}

output "workload_pool_cidr" {
  value = local.workload_pool_cidr
}