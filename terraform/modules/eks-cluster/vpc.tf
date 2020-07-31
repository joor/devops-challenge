#
# VPC Resources
#  * VPC
#  * Subnets
#  * Internet Gateway
#  * Route Table
#

data "aws_region" "current" {}

data "aws_route_table" "main" {
  vpc_id = "${aws_vpc.main.id}"
}

resource "aws_vpc" "main" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_hostnames = true

  tags = "${
    map(
     "Name", "${var.cluster_name}",
     "kubernetes.io/cluster/${var.cluster_name}", "shared",
    )
  }"
}

resource "aws_subnet" "main" {
  count = "${length(var.availability_zones)}"

  availability_zone = "${var.availability_zones[count.index]}"
  cidr_block        = "${cidrsubnet(var.vpc_cidr, var.subnet_newbits, count.index)}"
  vpc_id            = "${aws_vpc.main.id}"

  tags = "${
    map(
     "Name", "${var.cluster_name}-${var.availability_zones[count.index]}",
     "kubernetes.io/cluster/${var.cluster_name}", "shared",
    )
  }"
}

resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "${var.cluster_name}"
  }
}

resource "aws_route" "internet" {
  route_table_id = "${data.aws_route_table.main.id}"

  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.main.id}"
}

resource "aws_route_table_association" "main" {
  count = "${length(var.availability_zones)}"

  subnet_id      = "${aws_subnet.main.*.id[count.index]}"
  route_table_id = "${data.aws_route_table.main.id}"
}
