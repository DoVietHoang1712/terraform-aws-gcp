output "VPC_ID" {
  value = module.vpc.vpc.id
}
output "Pirvate_subnet" {
  value = module.vpc.public_subnet
}
output "Route_table" {
  value = module.aws-vpm-gcp.route_table
}