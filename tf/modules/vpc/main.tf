# Data
data "aws_region" "current" { }

data "aws_availability_zones" "available" {
  state = "available"
}


# Locals
locals {
  location_abr       = replace(data.aws_region.current.name, "/^([a-z]{2})-(.)(.{0.})-([0-9])/", "$1$2$4")
  availability_zones = data.aws_availability_zones.available.names
  subnet_abr         = [for az in data.aws_availability_zones.available.names : replace(az, "/^([a-z]{2})-(.)(.{0.})-([0-9])/", "$1$2$4")]
  subnet_count       = length(data.aws_availability_zones.available.names)

}

# VPC
resource "aws_vpc" "this" {
  cidr_block            = var.vpc_cidr_block
  enable_dns_hostnames  = var.enable_dns_hostnames
  enable_dns_support    = var.enable_dns_support

  tags = {
    Name = "${var.vpc_name}-${local.location_abr}-vpc"
  }
}

# Public Subnets
resource "aws_subnet" "public" {
  count                   = local.subnet_count

  vpc_id                  = aws_vpc.this.id
  availability_zone       = local.availability_zones[count.index]
  cidr_block              = cidrsubnet(var.vpc_cidr_block, var.subnet_netbits, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.vpc_name}-${local.subnet_abr[count.index]}-public-subnet"
  }
}

# Private Subnets
resource "aws_subnet" "private" {
  count                   = local.subnet_count

  vpc_id                  = aws_vpc.this.id
  availability_zone       = local.availability_zones[count.index]
  cidr_block              = cidrsubnet(var.vpc_cidr_block, var.subnet_netbits, count.index + local.subnet_count)
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.vpc_name}-${local.subnet_abr[count.index]}-private-subnet"
  }
}

# EIPs
resource "aws_eip" "nat" {
  count = var.create_nat ? 1 : 0

  vpc = true
}

# Gateways
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.vpc_name}-${local.location_abr}-igw"
  }
}

resource "aws_nat_gateway" "this" {
  count         = var.create_nat ? 1 : 0

  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "${var.vpc_name}-${local.location_abr}-nat-gw"
  }
}

# Route table, routes & associations
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.vpc_name}-${local.location_abr}-public-rtb"
  }
}

resource "aws_route" "internet" {
  route_table_id          = aws_route_table.public.id
  destination_cidr_block  = "0.0.0.0/0"
  gateway_id              = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  for_each        = aws_subnet.public

  subnet_id       = each.value.id
  route_table_id  = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.vpc_name}-${local.location_abr}-private-rtb"
  }
}

resource "aws_route" "nat" {
  count                   = var.create_nat ? 1 : 0
  route_table_id          = aws_route_table.private.id
  destination_cidr_block  = "0.0.0.0/0"
  nat_gateway_id          = aws_nat_gateway.this[0].id
}

resource "aws_route_table_association" "private" {
  for_each        = aws_subnet.private

  subnet_id       = each.value.id
  route_table_id  = aws_route_table.private.id
}


# Security groups
resource "aws_security_group" "this" {
  name = "${var.vpc_name}-${local.location_abr}-default-sg"
  description = "Default security group for resources"
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.vpc_name}-${local.location_abr}-default-sg"
  }
}

resource "aws_security_group_rule" "default_ingress" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  self              = true
  security_group_id = aws_security_group.this.id
}

resource "aws_security_group_rule" "default_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.this.id
}
