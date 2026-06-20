// Copyright (c) 2026 Valter Simes
// Licensed under the PolyForm Noncommercial License 1.0.0
// See LICENSE file at the repo root for full terms.

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

resource "aws_key_pair" "key_algarrobo" {
  key_name   = "${var.name_prefix}-key"
  public_key = var.public_key
}

resource "aws_key_pair" "bastion_key_algarrobo" {
  count      = var.enable_private_subnet ? 1 : 0
  key_name   = "${var.name_prefix}-bastion-key"
  public_key = var.bastion_public_key
}

resource "aws_instance" "server_algarrobo" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  key_name      = aws_key_pair.key_algarrobo.key_name
  primary_network_interface {
    network_interface_id = var.enable_private_subnet ? var.private_network_interface_id : var.public_network_interface_id
  }
  root_block_device {
    volume_size = 30
    volume_type = "gp2"
  }
  tags = {
    Terraform = true
    Name      = "${var.name_prefix}_instance"
  }
}

resource "aws_instance" "server_bastion" {
  count         = var.enable_private_subnet ? 1 : 0
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  key_name      = aws_key_pair.bastion_key_algarrobo[0].key_name
  primary_network_interface {
    network_interface_id = var.public_network_interface_id
  }
  root_block_device {
    volume_size = 30
    volume_type = "gp2"
  }
  tags = {
    Terraform = true
    Name      = "${var.name_prefix}_bastion_instance"
  }
}