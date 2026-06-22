variable "public_key" {
  type        = string
  description = "Pulic key string for the MQTT hosting instance"
}

variable "bastion_public_key" {
  type        = string
  description = "Pulic key string for the bastion instance"
}

variable "ssh_allowlist" {
  type        = string
  description = "IP to allowlist ssh and dashboard access"
}

variable "vpc_cidr_block" {
  type        = string
  default     = "10.0.0.0/16"
  description = "CIDR block for the VPC, parameterized so not to conflict with other VPCs"
}

variable "enable_private_subnet" {
  type        = bool
  default     = true
  description = "Flag to host services in a private subnet as good practice, behind a public subnet and NLB"
}

variable "dns_name" {
  type        = string
  description = "The host domain to use for MQTT and Grafana"
}

variable "availability_zone" {
  type        = string
  description = "Set a particular AZ for the target groups in the NLB"
}