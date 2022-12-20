output "aws_region" {
  description = "AWS region"
  value       = data.aws_region.current.name
}

output vpc_id {
  description = "VPC id"
  value       = aws_vpc.this.id
}

output vpc_cidr {
  description = "VPC CIDR"
  value       = aws_vpc.this.cidr_block
}

output public_subnet_id {
  description = "Public subnet ids"
  value       = aws_subnet.public[*].id
}

output public_subnet_cidr {
  description = "Map of public subnet id to cidr block"
  value       = {
    for subnet in aws_subnet.public :
    subnet.id => subnet.cidr_block
  }
}

output private_subnet_id {
  description = "Private subnet ids"
  value       = aws_subnet.private[*].id
}

output private_subnet_cidr {
  description = "Map of private subnet id to cidr block"
  value       = {
    for subnet in aws_subnet.private :
    subnet.id => subnet.cidr_block
  }
}

output security_group_id {
  description = "Default security group id"
  value       = aws_security_group.this.id
}

output nat_id {
  description = "The ID of the NAT gateway"
  value       = aws_nat_gateway.this[0].id
}

output nat_public_ip {
  description = "Public IP address of NAT gateway"
  value       = aws_nat_gateway.this[0].public_ip
}
