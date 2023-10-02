# Define an AWS VPC (Virtual Private Cloud) resource named "custom_vpc"
resource "aws_vpc" "custom_vpc" {
  cidr_block = var.vpc_cidr_block

  tags = merge(var.tags, {
    Name = "MyCustomVPC"
  })
}

# Define a public subnet "public_subnet_a" in Availability Zone ap-southeast-1a
resource "aws_subnet" "public_subnet_a" {
  vpc_id                  = aws_vpc.custom_vpc.id
  cidr_block              = var.public_subnet_a_cidr
  availability_zone       = var.availability_zone_a
  map_public_ip_on_launch = true # Associate a public IP with instances launched in this subnet

  tags = merge(var.tags, {
    Name = "PublicSubnetA"
  })
}

# Define a private subnet "private_subnet_a" in Availability Zone ap-southeast-1a
resource "aws_subnet" "private_subnet_a" {
  vpc_id            = aws_vpc.custom_vpc.id
  cidr_block        = var.private_subnet_a_cidr
  availability_zone = var.availability_zone_a

  tags = merge(var.tags, {
    Name = "PrivateSubnetA"
  })
}

# Define a public subnet "public_subnet_b" in Availability Zone ap-southeast-1b
resource "aws_subnet" "public_subnet_b" {
  vpc_id                  = aws_vpc.custom_vpc.id
  cidr_block              = var.public_subnet_b_cidr
  availability_zone       = var.availability_zone_b
  map_public_ip_on_launch = true # Associate a public IP with instances launched in this subnet

  tags = merge(var.tags, {
    Name = "PublicSubnetB"
  })
}

# Define a private subnet "private_subnet_b" in Availability Zone ap-southeast-1b
resource "aws_subnet" "private_subnet_b" {
  vpc_id            = aws_vpc.custom_vpc.id
  cidr_block        = var.private_subnet_b_cidr
  availability_zone = var.availability_zone_b

  tags = merge(var.tags, {
    Name = "PrivateSubnetB"
  })
}

# Create an Internet Gateway for the VPC
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.custom_vpc.id

  tags = merge(var.tags, {
    Name = "VPCInternetGateway"
  })
}

# Allocate an Elastic IP address for NAT Gateway in Availability Zone 1
resource "aws_eip" "eip_a" {
  vpc = true
}

# Create a NAT Gateway in Public Subnet A
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.eip_a.id
  subnet_id     = aws_subnet.public_subnet_a.id

  tags = merge(var.tags, {
    Name = "NATGateway"
  })
}

# Create a private route table for Private Subnet A
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.custom_vpc.id

  route {
    cidr_block = var.all_cidr
    gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = merge(var.tags, {
    Name = "PrivateRouteTable"
  })
}

# Associate private route table with Private Subnet A
resource "aws_route_table_association" "private_association_a" {
  subnet_id      = aws_subnet.private_subnet_a.id
  route_table_id = aws_route_table.private_route_table.id
}

# Associate private route table with Private Subnet B
resource "aws_route_table_association" "private_association_b" {
  subnet_id      = aws_subnet.private_subnet_b.id
  route_table_id = aws_route_table.private_route_table.id
}

# Create a public route table for Public Subnets
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.custom_vpc.id

  route {
    cidr_block = var.all_cidr
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(var.tags, {
    Name = "PublicRouteTable"
  })
}

# Associate public route table with Public Subnet A
resource "aws_route_table_association" "public_association_a" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public_route_table.id
}

# Associate public route table with Public Subnet B
resource "aws_route_table_association" "public_association_b" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.public_route_table.id
}
