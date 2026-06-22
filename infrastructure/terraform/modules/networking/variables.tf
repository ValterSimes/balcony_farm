variable "public_sg_rules" {
  type = list(object({
    type        = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  description = "List of security group rules for internet facing security group"
}

variable "name_prefix" {
  type        = string
  description = "Name prefix for all resources"
}

variable "cidr_block" {
  type        = string
  description = "CIDR block for the VPC, parameterized so not to conflict with other VPCs"
}

variable "enable_private_subnet" {
  type        = bool
  description = "Flag to host services in a private subnet as good practice, behind a public subnet and NLB"
}

variable "dns_name" {
  type = string
}

variable "availability_zone" {
  type = string
}