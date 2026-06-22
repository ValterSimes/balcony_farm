variable "name_prefix" {
  type        = string
  description = "Name prefix for all resources"
}

variable "vpc_id" {
  type        = string
  description = "VPC id where to deploy NLB"
}

variable "public_subnet_id" {
  type        = string
  description = "Subnet where to deploz NLB"
}

variable "certificate_arn" {
  type        = string
  description = "ACM certificate ARN for TLS termination"
}

variable "security_group_id" {
  type        = string
  description = "SG to attach to the NLB"
}