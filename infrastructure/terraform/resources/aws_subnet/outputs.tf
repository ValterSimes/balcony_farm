output "cidr_block" {
  value       = aws_subnet.subnet_algarrobo.cidr_block
  description = "Returns the subnet CIDR"
}

output "network_interface_id" {
  value       = aws_network_interface.ni_algarrobo.id
  description = "Returns the subnet NIC"
}

output "subnet_id" {
  value       = aws_subnet.subnet_algarrobo.id
  description = "Returns the subnet ID"
}