resource "aws_lb" "nlb" {
  name                             = "${var.name_prefix}-nlb"
  internal                         = false
  load_balancer_type               = "network"
  enable_cross_zone_load_balancing = true
  security_groups                  = [var.security_group_id]

  subnet_mapping {
    subnet_id = var.public_subnet_id
  }

  tags = {
    Name = "${var.name_prefix}_nlb"
  }
}

# MQTTS listener — terminates TLS, forwards TCP to Mosquitto
resource "aws_lb_target_group" "mqtt" {
  name               = "${var.name_prefix}-mqtt"
  port               = 8883
  protocol           = "TCP"
  vpc_id             = var.vpc_id
  preserve_client_ip = false

  health_check {
    protocol = "TCP"
    port     = 8883
  }

  tags = {
    Name = "${var.name_prefix}_mqtt_tg"
  }
}

resource "aws_lb_listener" "mqtts" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = 8883
  protocol          = "TLS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mqtt.arn
  }
}

# HTTPS listener — terminates TLS, forwards to Grafana
resource "aws_lb_target_group" "grafana" {
  name               = "${var.name_prefix}-grafana"
  port               = 3000
  protocol           = "TCP"
  vpc_id             = var.vpc_id
  preserve_client_ip = false

  health_check {
    protocol = "TCP"
    port     = 3000
  }

  tags = {
    Name = "${var.name_prefix}_grafana_tg"
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = 443
  protocol          = "TLS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.grafana.arn
  }
}
