# Fetches a list of available AWS availability zones in the current region
data "aws_availability_zones" "available" {}

# Creates a new Virtual Private Cloud (VPC)
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr # The IP range for the entire VPC

  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc_name # Name tag for easier identification
  }
}

# Creates Public Subnets within the VPC
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs) # Creates multiple public subnets

  vpc_id = aws_vpc.main.id # Associates the subnet with the VPC
  cidr_block = var.public_subnet_cidrs[count.index] # Assigns a CIDR block to each subnet
  map_public_ip_on_launch = true # Ensures instances in this subnet get a public IP by default
  availability_zone = element(data.aws_availability_zones.available.names, count.index) # Spreads subnets across zones

  tags = {
    Name = "PublicSubnet-${count.index + 1}" # Helps indentify each public subnet
  }
}

# Creates Private Subnets within the VPC
resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs) # Creates multiple private subnets

  vpc_id = aws_vpc.main.id # Associates the subnet with the VPC
  cidr_block = var.private_subnet_cidrs[count.index] # Assigns a CIDR block to each subnet
  availability_zone = element(data.aws_availability_zones.available.names, count.index) # Spreads subnets across zones

  tags = {
    Name = "PrivateSubnet-${count.index + 1}" # Helps indentify each private subnet
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "MainIGW"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "PublicRouteTable"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "PrivateRouteTable"
  }
}

resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)

  subnet_id = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_nat_gateway" "main" {
  count = var.enable_nat ? 1 : 0 # Only create NAT if enabled

  allocation_id = aws_eip.nat[0].id
  subnet_id = aws_subnet.public[0].id # NAT should be in a public subnet

  tags = {
    Name = "MainNATGateway"
  }
}

resource "aws_eip" "nat" {
  count = var.enable_nat ? 1 : 0 # Elastic IP for NAT
}

resource "aws_route" "private_nat_route" {
  count = var.enable_nat ? 1 : 0

  route_table_id = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.main[0].id
}
