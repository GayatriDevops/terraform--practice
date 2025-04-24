
resource "aws_vpc" "dev" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true


}

# Internet Gateway (for public subnets)
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.dev.id

#   tags = merge({
#     Name = "${var.vpc_name}-igw"
#   }, var.tags)
}

# Public Subnets
resource "aws_subnet" "public" {
  count             = length(var.public_subnets)
  vpc_id            = aws_vpc.dev.id
  cidr_block        = var.public_subnets[count.index]
  availability_zone = var.availability_zones[count.index]

#   tags = merge({
#     Name = "public-subnet-${count.index + 1}"
#   }, var.tags)
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.dev.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

#   tags = merge({
#     Name = "${var.vpc_name}-public-rt"
#   }, var.tags)
}

# Associate public subnets with route table
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"
}

# NAT Gateway in the first public subnet
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id
}

#   tags = merge({
#     Name = "${var.vpc_name}-nat-gateway"
#   }, var.tags)

#   depends_on = [aws_internet_gateway.igw]
# }

# Private Subnets
resource "aws_subnet" "private" {
  count             = length(var.private_subnets)
  vpc_id            = aws_vpc.dev.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.availability_zones[count.index]

}
#   tags = merge({
#     Name = "private-subnet-${count.index + 1}"
#   }, var.tags)
# Private Route Table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.dev.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

#   tags = merge({
#     Name = "${var.vpc_name}-private-rt"
#   }, var.tags)
}

# Associate private subnets with private route table
resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
