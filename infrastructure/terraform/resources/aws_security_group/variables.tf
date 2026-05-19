variable "name_prefix" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "sg_rules" {
  type = list(object({
    type        = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
}

variable "description" {
  type = string
}