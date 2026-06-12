output "private_network_interface_id" {
  value = var.enable_private_subnet ? module.private_subnet[0].network_interface_id : null
}

output "public_network_interface_id" {
  value = module.public_subnet.network_interface_id
}

output "mqtt_target_group_arn" {
  value = var.enable_private_subnet ? module.nlb[0].mqtt_target_group_arn : null
}

output "grafana_target_group_arn" {
  value = var.enable_private_subnet ? module.nlb[0].grafana_target_group_arn : null
}