locals {
  primary_dns_ip_address   = cidrhost(local.private_subnet_cidr, 125)
  secondary_dns_ip_address = cidrhost(local.private_subnet_cidr, 126)
}

resource "aws_route53_zone" "main" {
  name = var.domain_name

  vpc {
    vpc_id = aws_vpc.main.id
  }
}

resource "aws_route53_resolver_endpoint" "main" {
  name      = "${var.system_id}-dns-endpoint"
  direction = "INBOUND"

  security_group_ids = [
    aws_security_group.allow_dns.id
  ]

  ip_address {
    subnet_id = aws_subnet.private.id
    ip        = local.primary_dns_ip_address
  }

  ip_address {
    subnet_id = aws_subnet.private.id
    ip        = local.secondary_dns_ip_address
  }
}

resource "aws_security_group" "allow_dns" {
  name        = "allow_dns"
  description = "Allow DNS inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = [var.toplevel_pool_cidr]
  }

  ingress {
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = [var.toplevel_pool_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_dns"
  }
}