resource "aws_vpc" "dev_vpc" {
  cidr_block = "10.20.0.0/16"
  tags = {
    Name   = "dev_vpc"
    "name" = "dev_vpc"
  }
}

resource "aws_subnet" "dev_subnet_public_1" {
  vpc_id                  = aws_vpc.dev_vpc.id
  cidr_block              = "10.20.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true
  tags = {
    Name   = "dev_subnet_public_1"
    "name" = "dev_subnet_public_1"
  }
}

resource "aws_internet_gateway" "dev_sub1_igw" {
  vpc_id = aws_vpc.dev_vpc.id
  tags = {
    Name   = "dev_sub1_igw"
    "name" = "dev_sub1_igwt"
  }
}

resource "aws_route_table" "dev_vpc_public_rt" {
  vpc_id = aws_vpc.dev_vpc.id
  tags = {
    Name   = "dev_vpc_public_rt"
    "name" = "dev_vpc_public_rt"
  }
}

resource "aws_route" "dev_route_1" {
  route_table_id         = aws_route_table.dev_vpc_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.dev_sub1_igw.id

}

resource "aws_route_table_association" "dev_public_route_1" {
  route_table_id = aws_route_table.dev_vpc_public_rt.id
  subnet_id      = aws_subnet.dev_subnet_public_1.id

}
