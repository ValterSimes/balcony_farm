locals {
  name_prefix = "algarrobo"
}

module "networking" {
  source                = "../../modules/networking"
  name_prefix           = local.name_prefix
  cidr_block            = var.vpc_cidr_block
  enable_private_subnet = var.enable_private_subnet
  aws_instance_id       = module.compute.aws_instance_id
  dns_name              = var.dns_name
  availability_zone = var.availability_zone
  public_sg_rules = [
    {
      type        = "ingress"
      from_port   = 8883
      to_port     = 8883
      protocol    = "tcp"
      cidr_blocks = [var.ssh_allowlist]
    },
    {
      type        = "ingress"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = [var.ssh_allowlist]
    },
    {
      type        = "ingress"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [var.ssh_allowlist]
    },
    {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
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


