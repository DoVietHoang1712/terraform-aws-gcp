output "vpc" {
  value = aws_vpc.vpc
}

output "public_subnet" {
  value = aws_subnet.public_subnet.*.id
}

output "igw" {
  value = aws_internet_gateway.ig.id
}
