resource "aws_security_group" "sg_algarrobo" {
  description = var.description
  name        = "${var.name_prefix}_sg"
  vpc_id      = var.vpc_id

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