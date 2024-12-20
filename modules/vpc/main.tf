data "aws_availability_zones" "available" {}
data "aws_region" "current" {}

resource "aws_vpc" "my_test_vpc" {
  cidr_block = var.cidr_block

  tags = {
    Name      = var.vpc_name
    terraform = true
  }
}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_test_vpc.id

  tags = {
    terraform = true
  }
}

#nat gateway
resource "aws_nat_gateway" "nat_gateway" {

  allocation_id = aws_eip.elastic_ip.id
  subnet_id     = aws_subnet.public_subnet.id

}

#private subnet
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.my_test_vpc.id
  cidr_block        = cidrsubnet(var.cidr_block, 8, 1)
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    terraform = true
  }
}

#public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.my_test_vpc.id
  cidr_block        = cidrsubnet(var.cidr_block, 8, 2)
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    terraform = true
  }
}

#public route table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.my_test_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    terraform = true
  }
}

#private route table
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.my_test_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gateway.id
  }
}


#Create route table associations
resource "aws_route_table_association" "public" {
  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = aws_subnet.public_subnet.id
}

resource "aws_route_table_association" "private" {
  route_table_id = aws_route_table.private_route_table.id
  subnet_id      = aws_subnet.private_subnet.id
}

#Create EIP for NAT Gateway
resource "aws_eip" "elastic_ip" {
  domain     = "vpc"

}