variable "public_key" {
  type = string
  description = "Pulic key string for the MQTT hosting instance"
}

variable "private_network_interface_id" {
  type = string
  description =  "NIC for the instance hosting services when private subnet is enabled"
}

variable "public_network_interface_id" {
  type = string
  description = "NIC for bastion"
}

variable "name_prefix" {
  type = string
  description = "Name prefix for all resources"
}

variable "bastion_public_key" {
  type = string
  description = "Pulic key string for bastion instance"
}

variable "enable_private_subnet" {
  type = bool
  description = "Flag to host services in a private subnet as good practice, enables the creation of a bastion"
}