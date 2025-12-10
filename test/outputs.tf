#--------------------------------------------------------------
# Outputs
#--------------------------------------------------------------

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.example.vpc_id
}

output "cidr_block" {
  description = "The primary CIDR of the VPC"
  value       = module.example.cidr_block
}

output "intra_subnets" {
  description = "List of Ids for intra subnets"
  value       = module.example.intra_subnets
}

output "private_subnets" {
  description = "List of Ids for private subnets"
  value       = module.example.private_subnets
}

output "public_subnets" {
  description = "List of Ids for private subnets"
  value       = module.example.public_subnets
}

output "services_subnets" {
  description = "List of IDs of private subnets"
  value       = module.example.services_subnets
}

output "secondary_public_subnets" {
  description = "Map of secondary public subnet IDs"
  value       = module.example.secondary_public_subnets
}

output "secondary_private_subnets" {
  description = "Map of secondary private subnet IDs"
  value       = module.example.secondary_private_subnets
}

output "secondary_subnets_by_env" {
  description = "Map of subnet IDs grouped by environment"
  value       = module.example.secondary_subnets_by_env
}

output "secondary_route_tables_by_env" {
  description = "Map of secondary route table IDs by environment"
  value       = module.example.secondary_route_tables_by_env
}

output "network_acls_by_env" {
  description = "Network ACLs by environment"
  value       = module.example.network_acls_by_env
}

output "vpc_endpoints" {
  description = "Array containing the full resource object and attributes for all endpoints created"
  value       = module.example.vpc_endpoints
}

output "vpc_cidrs" {
  description = "List of all CIDR blocks associated with the VPC"
  value       = module.example.vpc_cidrs
}