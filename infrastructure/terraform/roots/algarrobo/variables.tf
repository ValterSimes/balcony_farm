variable "public_key" {
  type = string
}

variable "bastion_public_key" {
  type = string
}

variable "ssh_allowlist" {
  type = string
}

variable "vpc_cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}

variable "enable_private_subnet" {
  type    = bool
  default = true
}

variable "dns_name" {
  type = string
}