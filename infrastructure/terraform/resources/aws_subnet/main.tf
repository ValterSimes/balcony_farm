locals {
  subnet_cidr = cidrsubnet(var.vpc_cidr, 8, var.subnet_index + 1)
}

resource "aws_subnet" "subnet_algarrobo" {
  vpc_id     = var.vpc_id
  cidr_block = local.subnet_cidr
  availability_zone = var.availability_zone
  tags = {
    Name = "${var.name_prefix}_subnet"
  }
}

resource "aws_network_interface" "ni_algarrobo" {
  subnet_id       = aws_subnet.subnet_algarrobo.id
  security_groups = [var.security_group_id]

  tags = {
    Name = "${var.name_prefix}_ni"
  }
}

resource "aws_route_table_association" "rta_algarrobo" {
  subnet_id      = aws_subnet.subnet_algarrobo.id
  route_table_id = aws_route_table.rt_algarrobo.id
}

resource "aws_route_table" "rt_algarrobo" {
  vpc_id = var.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    gateway_id     = var.is_public ? var.gateway_id : null
    nat_gateway_id = var.is_public ? null : var.gateway_id
  }

  tags = {
    Name = "${var.name_prefix}_rt"
  }
}