variable "vpc_id" {
  type = string
}

variable "region" {
  type = string
}

variable "gcp_network" {
  type        = string
  description = "GCP Network Name"
  default     = "hoangdv-network"
}

variable "gcp_subnet" {
  type        = string
  description = "GCP Network Subnet Name"
  default     = "private-network"
}

variable "vpn_name" {
  type    = string
  default = "aws-vpn-gcp"
}

variable "name" {
  type    = string
  default = "aws-vpn-gcp"
}

variable "tunnel_name" {
  type    = string
  default = "aws-vpn-gcp-tunnel"
}

variable "aws_cidr_block" {
  type = string
}

variable "account_id" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "private_subnet_id" {
  type = list(string)
}

variable "public_subnet_id" {
  type = list(string)
}

variable "ig_id" {
  type = string
}

variable "project_id" {
  type    = string
  default = "vpn-site-to-site-aws-gcp"
}
