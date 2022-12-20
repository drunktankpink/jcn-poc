variable vpc_name {
  description = "Name of VPC"
  type        = string
}

variable vpc_cidr_block {
  description = "CIDR block for VPC"
  type        = string
}

variable subnet_netbits {
  description = "Netbits by which to extend vpc cidr"
  type        = number
  default     = 8
}

variable create_nat {
  description = "Determine if a NAT gateway is to be created"
  type        = bool
  default     = false
}

variable enable_dns_support {
  description = "Decide if to enable/disable DNS support in the VPC"
  type        = bool
  default     = true
}

variable enable_dns_hostnames {
  description = "Decide if to enable/disable DNS hostnames in the VPC"
  type        = bool
  default     = true
}
