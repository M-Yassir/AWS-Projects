# VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "main-vpc"
  }
}

# IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "main-igw"
  }
}

# NAT & EIP
resource "aws_eip" "eip" {}

resource "aws_nat_gateway" "ngw" {
  subnet_id = aws_subnet.public_subnet_1.id
  allocation_id = aws_eip.eip.id
  tags = {
    Name = "main-ngw"
  }
}

# Route Tables

# Public Route Table
resource "aws_route_table" "public_rtb" {
  vpc_id = aws_vpc.main.id
  tags = { Name = "public-rtb" }
}

# Private Route Table
resource "aws_route_table" "private_rtb" {
  vpc_id = aws_vpc.main.id
  tags = { Name = "private-rtb" }
}

# Routes

resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_rtb.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route" "private_route" {
  route_table_id         = aws_route_table.private_rtb.id 
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.ngw.id
}

# route_table_associations

resource "aws_route_table_association" "rtba_public_1" {
    subnet_id      = aws_subnet.public_subnet_1.id
    route_table_id = aws_route_table.public_rtb.id
}

resource "aws_route_table_association" "rtba_public_2" {
    subnet_id      = aws_subnet.public_subnet_2.id
    route_table_id = aws_route_table.public_rtb.id
}

resource "aws_route_table_association" "rtba_private_3" {
    subnet_id      = aws_subnet.private_subnet_3.id
    route_table_id = aws_route_table.private_rtb.id
}

resource "aws_route_table_association" "rtba_private_4" {
    subnet_id      = aws_subnet.private_subnet_4.id
    route_table_id = aws_route_table.private_rtb.id
}

resource "aws_route_table_association" "rtba_private_5" {
    subnet_id      = aws_subnet.DB_subnet_5.id
    route_table_id = aws_route_table.private_rtb.id
}

resource "aws_route_table_association" "rtba_private_6" {
    subnet_id      = aws_subnet.DB_subnet_6.id
    route_table_id = aws_route_table.private_rtb.id
}

# Subnets

resource "aws_subnet" "public_subnet_1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "public_subnet_1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "public_subnet_2"
  }
}

resource "aws_subnet" "private_subnet_3" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "private_subnet_3"
  }
}

resource "aws_subnet" "private_subnet_4" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "private_subnet_4"
  }
}

resource "aws_subnet" "DB_subnet_5" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.5.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "DB_subnet_5"
  }
}

resource "aws_subnet" "DB_subnet_6" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.6.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "DB_subnet_6"
  }
}

# db_subnet_group

resource "aws_db_subnet_group" "dbsg" {
    name = "main"
    subnet_ids = [aws_subnet.DB_subnet_5.id, aws_subnet.DB_subnet_6.id]
}
