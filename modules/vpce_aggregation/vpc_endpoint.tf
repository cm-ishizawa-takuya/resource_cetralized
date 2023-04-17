module "vpc_endpoint" {
  for_each = toset(var.service_codes)

  source            = "./modules/vpc_endpoint"
  system_id         = var.system_id
  region_name       = var.region_name
  service_code      = each.value
  vpc_id            = aws_vpc.main.id
  subnet_id         = aws_subnet.private.id
  security_group_id = aws_security_group.allow_https.id
  dns_vpc_id        = var.dns_vpc_id
}

resource "aws_security_group" "allow_https" {
  name        = "allow_https"
  description = "Allow HTTPS inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 443
    to_port     = 443
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
    Name = "allow_https"
  }
}