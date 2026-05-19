resource "aws_vpc" "vpc_algarrobo" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "${var.name_prefix}_vpc"
  }
}

resource "aws_subnet" "subnet_algarrobo" {
  vpc_id     = aws_vpc.vpc_algarrobo.id
  cidr_block = "10.0.1.0/24"
}

resource "aws_network_interface" "ni_algarrobo" {
  subnet_id       = aws_subnet.subnet_algarrobo.id
  security_groups = [aws_security_group.sg_algarrobo.id]

  tags = {
    Name = "${var.name_prefix}_primary_network_interface"
  }
}

resource "aws_security_group" "sg_algarrobo" {
  description = "Allow algarrobo access"
  name        = "${var.name_prefix}_sg"
  vpc_id      = aws_vpc.vpc_algarrobo.id

  tags = {
    Name = "${var.name_prefix}_allow_ssh"
  }
}

resource "aws_security_group_rule" "nsg_algarrobo" {
  count             = length(var.sg_rules)
  type              = var.sg_rules[count.index].type
  from_port         = var.sg_rules[count.index].from_port
  to_port           = var.sg_rules[count.index].to_port
  protocol          = var.sg_rules[count.index].protocol
  cidr_blocks       = var.sg_rules[count.index].cidr_blocks
  security_group_id = aws_security_group.sg_algarrobo.id
}

resource "aws_eip" "eip_algarrobo" {
  network_interface = aws_network_interface.ni_algarrobo.id
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
resource "aws_route_table" "rt_algarrobo" {
  vpc_id = aws_vpc.vpc_algarrobo.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.name_prefix}_rt"
  }
}

resource "aws_route_table_association" "rta_algarrobo" {
  subnet_id      = aws_subnet.subnet_algarrobo.id
  route_table_id = aws_route_table.rt_algarrobo.id
}