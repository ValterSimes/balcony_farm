variable "vpc_id" {
  type        = string
  description = "VPC id where to deploy subnets"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC, parameterized so not to conflict with other VPCs"
}

variable "subnet_index" {
  type        = number
  description = "Used to define each subnet CIDR"
}

variable "name_prefix" {
  type        = string
  description = "Name prefix for all resources"
}

variable "gateway_id" {
  type        = string
  description = "GW ID for the subnet's route table to enable outbound access"
}

variable "security_group_id" {
  type        = string
  description = "SG to attach to the subnet's NIC"
}

variable "availability_zone" {
  type        = string
  description = "Set a particular AZ for the subnet to match the target groups in the NLB"
}

variable "is_public" {
  type        = bool
  description = "Flag to identfy if it's a public or private subnet"
}