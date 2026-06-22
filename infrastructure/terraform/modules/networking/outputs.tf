output "private_network_interface_id" {
  value = var.enable_private_subnet ? module.private_subnet[0].network_interface_id : null
  description = "Returns the private subnet NIC ID if private subnet enabled"
}

output "public_network_interface_id" {
  value = module.public_subnet.network_interface_id
  description = "Returns public subnet NIC ID"
}

output "mqtt_target_group_arn" {
  value = var.enable_private_subnet ? module.nlb[0].mqtt_target_group_arn : null
  description = "Returns NLB target group arn pointing to Mosquitto if private subnet enabled"
}

output "grafana_target_group_arn" {
  value = var.enable_private_subnet ? module.nlb[0].grafana_target_group_arn : null
  description = "Returns NLB target group arn pointing to Grafana if private subnet enabled"
}