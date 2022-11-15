resource "aws_vpc" "vpc" {
	cidr_block = var.vpc_cidr
	enable_dns_hostnames = true
	tags = {
		"Name" = var.vpc_name
	}
}

resource "aws_subnet" "private_subnet" {
	count = length(var.subnets.private)

	vpc_id = aws_vpc.vpc.id
	cidr_block = var.subnets.private[count.index]
	availability_zone = var.subnets.zone[count.index % length(var.subnets.zone)]

	tags = {
		"Name" = "private-subnet"
	}
}

resource "aws_subnet" "public_subnet" {
	count = length(var.subnets.public)

	vpc_id = aws_vpc.vpc.id
	cidr_block = var.subnets.public[count.index]
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