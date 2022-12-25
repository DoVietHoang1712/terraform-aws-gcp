data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  owners = ["099720109477"]
}

resource "aws_customer_gateway" "gcp_customer_gateway" {
  bgp_asn    = 65000
  ip_address = google_compute_address.static.address
  type       = "ipsec.1"
  tags = {
    "Name" = "gcp-customer-gateway"
  }
}

resource "aws_vpn_gateway" "vgw" {
  vpc_id = var.vpc_id
  tags = {
    "Name" = "vgw-vpc"
  }
}

resource "aws_vpn_connection" "stsvpn" {
  customer_gateway_id = aws_customer_gateway.gcp_customer_gateway.id
  vpn_gateway_id      = aws_vpn_gateway.vgw.id

  static_routes_only   = true
  type                 = aws_customer_gateway.gcp_customer_gateway.type
  tunnel1_ike_versions = ["ikev1"]

  tags = {
    "Name" = "aws-vpn-gcp"
  }
}

resource "aws_vpn_connection_route" "vpn-route" {
  vpn_connection_id      = aws_vpn_connection.stsvpn.id
  destination_cidr_block = google_compute_subnetwork.default.ip_cidr_range
}

resource "aws_security_group" "sg" {
  name        = "gcp-sg"
  description = "Allow all trafic from gcp"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [google_compute_subnetwork.default.ip_cidr_range, "0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "gcp-sg"
  }
}

resource "aws_instance" "aws-gcp" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  vpc_security_group_ids      = [aws_security_group.sg.id]
  associate_public_ip_address = true
  subnet_id                   = var.subnet_id[0]
  tags = {
    "Name" = "aws-gcp"
  }
}

resource "aws_route_table" "public" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.ig_id
  }
  route {
    cidr_block = google_compute_subnetwork.default.ip_cidr_range
    gateway_id = aws_vpn_gateway.vgw.id
  }
  # route = [{
  # 	cidr_block = "0.0.0.0/0"
  # 	gateway_id = aws_internet_gateway.ig.id
  # }]

  tags = {
    "Name" = "PublicRouteTable"
  }
}

resource "aws_route_table_association" "public_association" {
  for_each       = { for k, v in var.subnet_id : k => v }
  subnet_id      = each.value
  route_table_id = aws_route_table.public.id
}
