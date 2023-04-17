output "primary_dns_ip_address" {
  value = local.primary_dns_ip_address
}

output "secondary_dns_ip_address" {
  value = local.secondary_dns_ip_address
}

output "zone_id" {
  value = aws_route53_zone.main.id
}

output "domain_name" {
  value = aws_route53_zone.main.name
}

output "vpc_id" {
  value = aws_vpc.main.id
}