locals {
  private_subnet_cidr = cidrsubnet(aws_vpc.main.cidr_block, 1, 1)
  transit_subnet_cidr = cidrsubnet(aws_vpc.main.cidr_block, 1, 0)
}

# -- VPC
resource "aws_vpc" "main" {
  ipv4_ipam_pool_id    = var.ipam_pool_id
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${local.prefix}-vpc"
  }
}

# -- Subnet
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = local.private_subnet_cidr
  availability_zone = var.availability_zone

  tags = {
    Name = "${local.prefix}-subnet-private"
  }
}

resource "aws_subnet" "transit" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = local.transit_subnet_cidr
  availability_zone = var.availability_zone

  tags = {
    Name = "${local.prefix}-subnet-transit"
  }
}

# -- Transit Gateway
resource "aws_ec2_transit_gateway_vpc_attachment" "transit" {
  vpc_id             = aws_vpc.main.id
  subnet_ids         = [aws_subnet.transit.id]
  transit_gateway_id = var.transit_gateway_id

  tags = {
    Name = "${local.prefix}-tgw-attachment"
  }
}

# -- Route Table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block         = var.toplevel_pool_cidr
    transit_gateway_id = var.transit_gateway_id
  }

  tags = {
    Name = "${local.prefix}-rtb-private"
  }

  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.transit
  ]
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table" "transit" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.prefix}-rtb-transit"
  }
}

resource "aws_route_table_association" "transit" {
  subnet_id      = aws_subnet.transit.id
  route_table_id = aws_route_table.transit.id
}

# -- DHCP Option
resource "aws_vpc_dhcp_options" "main" {
  domain_name = "${var.region_name}.compute.internal"
  domain_name_servers = [
    var.primary_dns_ip_address,
    var.secondary_dns_ip_address,
  ]

  tags = {
    Name = "${local.prefix}-dhcp-options"
  }
}

resource "aws_vpc_dhcp_options_association" "main" {
  vpc_id          = aws_vpc.main.id
  dhcp_options_id = aws_vpc_dhcp_options.main.id
}