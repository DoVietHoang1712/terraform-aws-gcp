data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  owners = ["099720109477"]
}

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    "Name" = var.vpc_name
  }
}

resource "aws_subnet" "private_subnet" {
  count = length(var.subnets.private)

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.subnets.private[count.index]
  availability_zone = var.subnets.zone[count.index % length(var.subnets.zone)]

  tags = {
    "Name" = "private-subnet"
  }
}

resource "aws_subnet" "public_subnet" {
  count = length(var.subnets.public)

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.subnets.public[count.index]
  availability_zone = var.subnets.zone[count.index % length(var.subnets.zone)]

  tags = {
    "Name" = "public-subnet"
  }
}

resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    "Name" = "MyIGW"
  }
}

resource "aws_eip" "nat_ip" {
  vpc = true
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_ip.id
  subnet_id     = aws_subnet.private_subnet[0].id

  tags = {
    "Name" = "MyNGW"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
}

resource "aws_route_table_association" "instance" {
  subnet_id      = aws_subnet.private_subnet[0].id
  route_table_id = aws_route_table.private.id
}

resource "aws_security_group" "bastion-sg" {
  name        = "bastion-sg"
  description = "Allow all trafic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "bastion-sg"
  }
}

resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  vpc_security_group_ids      = [aws_security_group.bastion-sg.id]
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public_subnet[0].id
  tags = {
    "Name" = "bastion"
  }
}
# resource "aws_route_table" "public" {
# 	vpc_id = aws_vpc.vpc.id

# 	route {
# 		cidr_block = "0.0.0.0/0"
# 		gateway_id = aws_internet_gateway.ig.id
# 	}

# 	tags = {
# 		"Name" = "PublicRouteTable"
# 	}
# }

# resource "aws_route_table_association" "public_association" {
# 	for_each = { for k, v in aws_subnet.public_subnet : k => v }
# 	subnet_id = each.value.id
# 	route_table_id = aws_route_table.public.id
# }
