output "cidr_block" {
  value = aws_subnet.subnet_algarrobo.cidr_block
}

output "network_interface_id" {
  value = aws_network_interface.ni_algarrobo.id
}

output "subnet_id" {
  value = aws_subnet.subnet_algarrobo.id
}