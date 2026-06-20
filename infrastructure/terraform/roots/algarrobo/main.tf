// Copyright (c) 2026 Valter Simes
// Licensed under the PolyForm Noncommercial License 1.0.0
// See LICENSE file at the repo root for full terms.

terraform {
    required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

locals {
  name_prefix = "algarrobo"
}

resource "aws_lb_target_group_attachment" "grafana" {
  count                   = var.enable_private_subnet ? 1 : 0
  target_group_arn = module.networking.grafana_target_group_arn
  target_id        = module.compute.aws_instance_id
  port             = 3000
}


resource "aws_lb_target_group_attachment" "mqtt" {
  count                   = var.enable_private_subnet ? 1 : 0
  target_group_arn = module.networking.mqtt_target_group_arn
  target_id        = module.compute.aws_instance_id
  port             = 1883
}

module "networking" {
  source                = "../../modules/networking"
  name_prefix           = local.name_prefix
  cidr_block            = var.vpc_cidr_block
  enable_private_subnet = var.enable_private_subnet
  dns_name              = var.dns_name
  availability_zone     = var.availability_zone
  public_sg_rules = var.enable_private_subnet ? [
      { type = "ingress", from_port = 8883, to_port = 8883, protocol = "tcp", cidr_blocks = [var.ssh_allowlist] },
      { type = "ingress", from_port = 443,  to_port = 443,  protocol = "tcp", cidr_blocks = [var.ssh_allowlist] },
      { type = "ingress", from_port = 22,   to_port = 22,   protocol = "tcp", cidr_blocks = [var.ssh_allowlist] },
      { type = "egress",  from_port = 0,    to_port = 0,    protocol = "-1",  cidr_blocks = ["0.0.0.0/0"] }
    ] : [
      { type = "ingress", from_port = 1883, to_port = 1883, protocol = "tcp", cidr_blocks = [var.ssh_allowlist] },
      { type = "ingress", from_port = 3000, to_port = 3000, protocol = "tcp", cidr_blocks = [var.ssh_allowlist] },
      { type = "ingress", from_port = 22,   to_port = 22,   protocol = "tcp", cidr_blocks = [var.ssh_allowlist] },
      { type = "egress",  from_port = 0,    to_port = 0,    protocol = "-1",  cidr_blocks = ["0.0.0.0/0"] }
    ]
}

module "compute" {
  source                       = "../../modules/compute"
  enable_private_subnet        = var.enable_private_subnet
  name_prefix                  = local.name_prefix
  public_key                   = var.public_key
  bastion_public_key           = var.bastion_public_key
  public_network_interface_id  = module.networking.public_network_interface_id
  private_network_interface_id = module.networking.private_network_interface_id
}


