#
# VPC Resources
#  * VPC
#  * Subnets
#  * Internet Gateway
#  * NAT Gateway
#  * Route Table
#  * EIP
#

data "aws_availability_zones" "available" {}

resource "aws_vpc" "terra" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "${var.resource_prefix}-terraform-vpc",
  }
}


resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.terra.id
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = "10.0.${count.index}.0/24"
  map_public_ip_on_launch = true

  tags = tomap({
    Name                                                               = "${var.resource_prefix}-terraform-public-subnet${count.index + 1}",
    "kubernetes.io/cluster/${var.resource_prefix}-${var.cluster_name}" = "shared",
  })
}


resource "aws_subnet" "private" {
  count                   = 2
  vpc_id                  = aws_vpc.terra.id
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = "10.0.1${count.index}.0/24"
  map_public_ip_on_launch = false

  tags = tomap({
    Name = "${var.resource_prefix}-terraform-private-subnet${count.index + 1}",
  })
}


resource "aws_internet_gateway" "terra" {
  vpc_id = aws_vpc.terra.id

  tags = {
    Name = "${var.resource_prefix}-terraform-eks-ig"
  }
}

resource "aws_nat_gateway" "terra" {
  allocation_id = aws_eip.nat.id
  subnet_id     = element(aws_subnet.public.*.id, 0)
  depends_on    = [aws_internet_gateway.terra]

  tags = {
    Name = "${var.resource_prefix}-terraform-nat-gw"
  }
}


resource "aws_route_table" "public" {
  vpc_id = aws_vpc.terra.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terra.id
  }

  tags = {
    Name = "${var.resource_prefix}-terraform-public-route"
  }
}


resource "aws_route_table" "private" {
  vpc_id = aws_vpc.terra.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.terra.id
  }

  tags = {
    Name = "${var.resource_prefix}-terraform-private-route",
  }
}


resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public.*.id[count.index]
  route_table_id = aws_route_table.public.id
}


resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = aws_subnet.private.*.id[count.index]
  route_table_id = aws_route_table.private.id
}


resource "aws_eip" "nat" {
  depends_on = [aws_internet_gateway.terra]

  tags = {
    Name = "${var.resource_prefix}-terraform-NAT"
  }
}


resource "aws_eip" "eip1" {
  tags = {
    Name = "${var.resource_prefix}-terraform-EIP1"
  }
}


resource "aws_eip" "eip2" {
  tags = {
    Name = "${var.resource_prefix}-terraform EIP2"
  }
}

