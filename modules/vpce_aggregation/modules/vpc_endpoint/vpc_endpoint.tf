locals {
  service_name = "com.amazonaws.${var.region_name}.${var.service_code}"
  domain_name  = "${var.service_code}.${var.region_name}.amazonaws.com"
}

resource "aws_vpc_endpoint" "main" {
  vpc_id              = var.vpc_id
  subnet_ids          = [var.subnet_id]
  vpc_endpoint_type   = "Interface"
  service_name        = local.service_name
  private_dns_enabled = false

  security_group_ids = [var.security_group_id]

  tags = {
    Name = "${var.system_id}-vpce-${var.service_code}"
  }
}

resource "aws_route53_zone" "main" {
  name = local.domain_name

  vpc {
    vpc_id = var.dns_vpc_id
  }
}

resource "aws_route53_record" "main" {
  zone_id = aws_route53_zone.main.id
  name    = local.domain_name
  type    = "A"

  alias {
    name                   = aws_vpc_endpoint.main.dns_entry[0]["dns_name"]
    zone_id                = aws_vpc_endpoint.main.dns_entry[0]["hosted_zone_id"]
    evaluate_target_health = false
  }
}