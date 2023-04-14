data "aws_ami" "latest_amazon_linux_2023" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

# -- Instance
resource "aws_instance" "test_instance" {
  ami                    = data.aws_ami.latest_amazon_linux_2023.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public.id
  iam_instance_profile   = var.instance_profile_name
  vpc_security_group_ids = [aws_security_group.allow_icmp.id]

  tags = {
    Name = "${local.prefix}-test-instance"
  }
}

resource "aws_security_group" "allow_icmp" {
  name        = "allow_icmp"
  description = "Allow ICMP inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_icmp"
  }
}

# -- DNS Record
resource "aws_route53_record" "test_instance" {
  zone_id = var.route53_zone_id
  name    = "${local.domain_host_name}.${var.parent_domain_name}"
  type    = "A"
  ttl     = 300
  records = [aws_instance.test_instance.private_ip]
}