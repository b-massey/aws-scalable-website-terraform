# VPC
resource "aws_vpc" "web_vpc" {
  cidr_block           = "${var.cidr}"
  enable_dns_hostnames = "${var.enable_dns_hostnames}"
  enable_dns_support   = "${var.enable_dns_support}"
  tags                 = "${merge(var.tags, map("Name", format("%s-vpc",var.name)))}"
}
 
# IGW
resource "aws_internet_gateway" "web_igw" {
  vpc_id = "${aws_vpc.web_vpc.id}"
  tags   = "${merge(var.tags, map("Name", format("%s-igw",var.name)))}"
}


# EIP
resource "aws_eip" "eip" {
  vpc      = true
  depends_on = ["aws_internet_gateway.web_igw"]
}

# Private Subnets
resource "aws_subnet" "private" {
  vpc_id            = "${aws_vpc.web_vpc.id}"
  cidr_block        = "${element(split(",", var.private_subnets), count.index)}"
  availability_zone = "${element(split(",", var.azs), count.index)}"
  count             = "${length(compact(split(",", var.private_subnets)))}"  
  tags              = "${merge(var.tags, map("Name", format("%s-private-subnet",var.name)))}"
}

# Public Subnets
resource "aws_subnet" "public" {
  vpc_id            = "${aws_vpc.web_vpc.id}"
  cidr_block        = "${element(split(",", var.public_subnets), count.index)}"
  availability_zone = "${element(split(",", var.azs), count.index)}"
  count             = "${length(compact(split(",", var.public_subnets)))}"
  tags              = "${merge(var.tags, map("Name", format("%s-public-subnet",var.name)))}"
}

# NAT Gateway
resource "aws_nat_gateway" "nat_gw" {
    allocation_id = "${aws_eip.eip.id}"
    subnet_id     = "${element(aws_subnet.public.*.id, count.index)}"
    depends_on = ["aws_internet_gateway.web_igw"]
}

# Public Route & Route Table
resource "aws_route_table" "public" {
  vpc_id    = "${aws_vpc.web_vpc.id}"
  route {
    cidr_block    = "0.0.0.0/0"
    gateway_id    = "${aws_internet_gateway.web_igw.id}"
  }
  tags       = "${merge(var.tags, map("Name", format("%s-public-route",var.name)))}"
}

resource "aws_route_table_association" "public" {
  subnet_id       = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id  = "${aws_route_table.public.id}"
}


# Private Route & Route Table
resource "aws_route_table" "private" {
  vpc_id    = "${aws_vpc.web_vpc.id}"
  route {
    cidr_block    = "0.0.0.0/0"
    gateway_id    = "${aws_nat_gateway.nat_gw.id}"
  }
  tags       = "${merge(var.tags, map("Name", format("%s-private-route",var.name)))}"
}

resource "aws_route_table_association" "private" {
  subnet_id       = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id  = "${aws_route_table.private.id}"
}
