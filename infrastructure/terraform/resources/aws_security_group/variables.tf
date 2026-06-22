variable "name_prefix" {
  type        = string
  description = "Name prefix for all resources"
}

variable "vpc_id" {
  type        = string
  description = "VPC id where to deploy SGs"
}

variable "sg_rules" {
  type = list(object({
    type        = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  description = "List of SG rules"
}

variable "description" {
  type        = string
  description = "Short description of the SG purpose"
}