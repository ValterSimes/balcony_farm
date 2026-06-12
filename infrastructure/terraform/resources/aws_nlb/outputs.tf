output "zone_id" {
  value = aws_lb.nlb.zone_id
}

output "dns_name" {
  value = aws_lb.nlb.dns_name
}

output "mqtt_target_group_arn" {
  value = aws_lb_target_group.mqtt.arn
}

output "grafana_target_group_arn" {
  value = aws_lb_target_group.grafana.arn
}