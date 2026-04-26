locals {
  name_prefix = "algarrobo"
}

module "networking" {
  source = "../modules/networking"
  name_prefix = local.name_prefix
  sg_rules = [
    {
        type              = "ingress" 
        from_port         = 22          
        to_port           = 22          
        protocol          = "tcp"       
        cidr_blocks       = [var.ssh_allowlist]
    }
  ]
}

module "compute" {
  source = "../modules/compute"
  name_prefix = local.name_prefix
  public_key = var.public_key
  network_interface_id = module.networking.aws_network_interface_id
}


