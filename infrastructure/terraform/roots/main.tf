locals {
  name_prefix = "algarrobo"
}

module "networking" {
  source      = "../modules/networking"
  name_prefix = local.name_prefix
  sg_rules = [
    {
      type        = "ingress"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [var.ssh_allowlist]
    },
    {
      type        = "ingress"
      from_port   = 1883
      to_port     = 1883
      protocol    = "tcp"
      cidr_blocks = [var.ssh_allowlist]
    },
    {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      }, {
      type        = "ingress"
      from_port   = 3000
      to_port     = 3000
      protocol    = "tcp"
      cidr_blocks = [var.ssh_allowlist]
    }
  ]
}

module "compute" {
  source               = "../modules/compute"
  name_prefix          = local.name_prefix
  public_key           = var.public_key
  network_interface_id = module.networking.aws_network_interface_id
}


