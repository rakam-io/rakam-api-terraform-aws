# This data source is included for ease of sample architecture deployment
# and can be swapped out as necessary.
data "aws_availability_zones" "available" {}

resource "aws_vpc" "rakam" {
  cidr_block = "10.0.0.0/16"

  tags = "${
    map(
      "Name", "terraform-eks-rakam-node",
      "kubernetes.io/cluster/${var.cluster-name}", "shared",
    )
  }"
}

resource "aws_subnet" "rakam" {
  count = 2

  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block        = "10.0.${count.index}.0/24"
  vpc_id            = "${aws_vpc.rakam.id}"

  tags = "${
    map(
      "Name", "terraform-eks-rakam-node",
      "kubernetes.io/cluster/${var.cluster-name}", "shared",
    )
  }"
}

resource "aws_internet_gateway" "rakam" {
  vpc_id = "${aws_vpc.rakam.id}"

  tags = {
    Name = "terraform-eks-rakam"
  }
}

resource "aws_route_table" "rakam" {
  vpc_id = "${aws_vpc.rakam.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.rakam.id}"
  }
}

resource "aws_route_table_association" "rakam" {
  count = 2

  subnet_id      = "${aws_subnet.rakam.*.id[count.index]}"
  route_table_id = "${aws_route_table.rakam.id}"
}