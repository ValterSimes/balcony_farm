output "zone_id" {
  value       = aws_lb.nlb.zone_id
  description = "Returns the NLB zone id for Route53 record alias"
}

output "dns_name" {
  value       = aws_lb.nlb.dns_name
  description = "Returns NLB DNS name"
}

output "mqtt_target_group_arn" {
  value       = aws_lb_target_group.mqtt.arn
  description = "Returns NLB target group arn pointing to Mosquitto"
}

output "grafana_target_group_arn" {
  value       = aws_lb_target_group.grafana.arn
  description = "Returns NLB target group arn pointing to Grafana"
}