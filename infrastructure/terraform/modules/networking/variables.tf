variable "public_sg_rules" {
  type = list(object({
    type        = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
}

variable "name_prefix" {
  type = string
}

variable "cidr_block" {
  type = string
}

variable "enable_private_subnet" {
  type = bool
}