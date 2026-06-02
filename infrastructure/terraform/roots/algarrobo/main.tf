locals {
  name_prefix = "algarrobo"
}

module "networking" {
  source                = "../../modules/networking"
  name_prefix           = local.name_prefix
  cidr_block            = var.vpc_cidr_block
  enable_private_subnet = var.enable_private_subnet
  aws_instance_id = module.compute.aws_instance_id
  public_sg_rules = [
    {
      type        = "ingress"
      from_port   = 8883
      to_port     = 8883
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      type        = "ingress"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
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
  source               = "../../modules/compute"
  name_prefix          = local.name_prefix
  public_key           = var.public_key
  network_interface_id = module.networking.private_network_interface_id
}


