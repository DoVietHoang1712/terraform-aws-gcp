variable "project" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "subnets" {
  type = map(any)
}

variable "vpc_name" {
  type = string
}