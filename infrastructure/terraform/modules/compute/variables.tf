variable "public_key" {
  type = string
}

variable "private_network_interface_id" {
  type = string
}

variable "public_network_interface_id" {
  type = string
}

variable "name_prefix" {
  type = string
}

variable "bastion_public_key" {
  type = string
}

variable "enable_private_subnet" {
  type = bool
}