resource "aws_vpc" "vpc_algarrobo" {
  cidr_block = var.cidr_block

  tags = {
    Name = "${var.name_prefix}_vpc"
  }
}

resource "aws_eip" "eip_algarrobo" {
  network_interface = module.public_subnet.network_interface_id
  domain            = "vpc"
  tags = {
    Name = "${var.name_prefix}_eip"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc_algarrobo.id

  tags = {
    Name = "${var.name_prefix}_igw"
  }
}

resource "aws_eip" "algarrobo_nat_eip" {
  count  = var.enable_private_subnet ? 1 : 0
  domain = "vpc"

  tags = {
    Name = "${var.name_prefix}_nat_eip"
  }
}

resource "aws_nat_gateway" "algarrobo_nat_gw" {
  count         = var.enable_private_subnet ? 1 : 0
  allocation_id = aws_eip.algarrobo_nat_eip[0].id
  subnet_id     = module.public_subnet.subnet_id

  tags = {
    Name = "${var.name_prefix}_nat_gw"
  }
}

resource "aws_acm_certificate" "algarrobo" {
  count         = var.enable_private_subnet ? 1 : 0
  domain_name       = "*.${var.dns_name}"
  validation_method = "DNS"

  tags = {
    Name = "algarrobo_cert"
  }
}

data "aws_route53_zone" "zone" {
  name = var.dns_name
}

resource "aws_route53_record" "dns_validation" {
  for_each = var.enable_private_subnet ? toset([var.dns_name]) : toset([])

  zone_id = data.aws_route53_zone.zone.zone_id
  name    = tolist(aws_acm_certificate.algarrobo[0].domain_validation_options)[0].resource_record_name
  type    = tolist(aws_acm_certificate.algarrobo[0].domain_validation_options)[0].resource_record_type
  records = [tolist(aws_acm_certificate.algarrobo[0].domain_validation_options)[0].resource_record_value]
  ttl     = 60
}

resource "aws_route53_record" "algarrobo" {
  count = var.enable_private_subnet ? 1 : 0
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = "algarrobo.${var.dns_name}"
  type    = "A"

  alias {
    name                   = module.nlb[0].dns_name
    zone_id                = module.nlb[0].zone_id
    evaluate_target_health = true
  }
}

resource "aws_acm_certificate_validation" "algarrobo" {
  count = var.enable_private_subnet ? 1 : 0
  certificate_arn         = aws_acm_certificate.algarrobo[0].arn
  validation_record_fqdns = [for record in aws_route53_record.dns_validation : record.fqdn]
}

module "nlb" {
  count         = var.enable_private_subnet ? 1 : 0
  source              = "../../resources/aws_nlb"
  name_prefix         = var.name_prefix
  vpc_id              = aws_vpc.vpc_algarrobo.id
  public_subnet_id    = module.public_subnet.subnet_id
  target_instance_id  = var.aws_instance_id
  certificate_arn     = aws_acm_certificate.algarrobo[0].arn
  security_group_id = module.public_security_group.id
}

module "public_subnet" {
  source            = "../../resources/aws_subnet"
  vpc_id            = aws_vpc.vpc_algarrobo.id
  vpc_cidr          = aws_vpc.vpc_algarrobo.cidr_block
  subnet_index      = 0
  availability_zone = var.availability_zone
  name_prefix       = "${var.name_prefix}_public"
  gateway_id        = aws_internet_gateway.igw.id
  security_group_id = module.public_security_group.id
}

module "private_subnet" {
  count             = var.enable_private_subnet ? 1 : 0
  source            = "../../resources/aws_subnet"
  vpc_id            = aws_vpc.vpc_algarrobo.id
  vpc_cidr          = aws_vpc.vpc_algarrobo.cidr_block
  subnet_index      = 1
  availability_zone = var.availability_zone
  name_prefix       = "${var.name_prefix}_private"
  gateway_id        = aws_nat_gateway.algarrobo_nat_gw[0].id
  security_group_id = module.private_security_group.id
}

module "public_security_group" {
  source      = "../../resources/aws_security_group"
  name_prefix = "${var.name_prefix}-public"
  vpc_id      = aws_vpc.vpc_algarrobo.id
  sg_rules    = var.public_sg_rules
  description = "NLB and bastion access"
}

module "private_security_group" {
  source      = "../../resources/aws_security_group"
  name_prefix = "${var.name_prefix}-private"
  vpc_id      = aws_vpc.vpc_algarrobo.id
  sg_rules = [
    {
      type        = "ingress"
      from_port   = 1883
      to_port     = 1883
      protocol    = "tcp"
      cidr_blocks = [module.public_subnet.cidr_block]
    },
    {
      type        = "ingress"
      from_port   = 3000
      to_port     = 3000
      protocol    = "tcp"
      cidr_blocks = [module.public_subnet.cidr_block]
    },
    {
      type        = "ingress"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [module.public_subnet.cidr_block]
    },
    {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
  description = "Algarrobo access"
}