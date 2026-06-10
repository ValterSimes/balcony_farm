variable "name_prefix" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_id" {
  type = string
}

variable "target_instance_id" {
  type = string
}

variable "certificate_arn" {
  type        = string
  description = "ACM certificate ARN for TLS termination"
}

variable "security_group_id" {
  type = string
}