locals {
  domain_host_name = "workload${var.workload_index}"
  prefix           = "${var.system_id}-${local.domain_host_name}"
}