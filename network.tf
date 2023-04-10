## creating vpc
resource "aws_vpc" "lb_vpc" {
  cidr_block = var.lb_vpc_info.lb_vpc_cidr
  tags = {
    Name = "lb_vpc"
  }
}
## creating subnet
resource "aws_subnet" "lb_subnet" {
  count             = length(var.lb_vpc_info.lb_subnet_names)
  vpc_id            = aws_vpc.lb_vpc.id
  cidr_block        = cidrsubnet(var.lb_vpc_info.lb_vpc_cidr, 8, count.index)
  availability_zone = "${var.region}${var.lb_vpc_info.lb_subnets_names_azs[count.index]}"
  tags = {
    Name = var.lb_vpc_info.lb_subnet_names[count.index]
  }
  depends_on = [
    aws_vpc.lb_vpc
  ]

}
## creating internetgate_way
resource "aws_internet_gateway" "igw_lb" {
  vpc_id = aws_vpc.lb_vpc.id
  tags = {
    Name = "igw_lb"
  }
  depends_on = [
    aws_vpc.lb_vpc
  ]
}
## creating route_table
resource "aws_route_table" "route_table_lb" {
  vpc_id = aws_vpc.lb_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_lb.id
  }
  tags = {
    Name = "igw_lb"
  }
  depends_on = [
    aws_internet_gateway.igw_lb
  ]
}
## creating route_table association
resource "aws_route_table_association" "lb_main_rt_association" {
  subnet_id      = aws_subnet.lb_subnet[0].id
  route_table_id = aws_route_table.route_table_lb.id
  depends_on = [
    aws_route_table.route_table_lb
  ]

}
resource "aws_route_table_association" "lb_main_rt_association1" {
  subnet_id      = aws_subnet.lb_subnet[1].id
  route_table_id = aws_route_table.route_table_lb.id
  depends_on = [
    aws_route_table.route_table_lb
  ]

}
## create security group
resource "aws_security_group" "terraformlb" {
  name        = "terraformlb"
  vpc_id      = aws_vpc.lb_vpc.id
  description = "allow all ports"
  ingress {
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "-1"
  }

  egress {
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "-1"
  }

  depends_on = [
    aws_subnet.lb_subnet
  ]
}