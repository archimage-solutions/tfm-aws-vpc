#--------------------------------------------------------------
# Outputs
#--------------------------------------------------------------

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "cidr_block" {
  description = "The primary CIDR of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "intra_subnets" {
  description = "List of Ids for intra subnets"
  value       = module.vpc.intra_subnets
}

output "private_subnets" {
  description = "List of Ids for private subnets"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "List of Ids for private subnets"
  value       = module.vpc.public_subnets
}

output "services_subnets" {
  description = "List of IDs of private subnets"
  value       = [for s in aws_subnet.service_subnet : s.id]
}

output "secondary_public_subnets" {
  description = "Map of secondary public subnet IDs"
  value       = { for k, v in aws_subnet.secondary_public : k => v.id }
}

output "secondary_private_subnets" {
  description = "Map of secondary private subnet IDs"
  value       = { for k, v in aws_subnet.secondary_private : k => v.id }
}

output "secondary_subnets_by_env" {
  description = "Map of subnet IDs grouped by environment"
  value = {
    for env_name, env_config in var.secondary_subnets : env_name => {
      public = {
        for name, subnet in aws_subnet.secondary_public :
        name => subnet.id if can(regex("^${env_name}-", name))
      }
      private = {
        for name, subnet in aws_subnet.secondary_private :
        name => subnet.id if can(regex("^${env_name}-", name))
      }
    } if length(var.secondary_subnets) > 0
  }
}

output "secondary_route_tables_by_env" {
  description = "Map of secondary route table IDs by environment"
  value = {
    for env_name, env_config in var.secondary_subnets : env_name => {
      public = contains(keys(aws_route_table.public), env_name) ? aws_route_table.public[env_name].id : null
      private = {
        for name, rt in aws_route_table.private :
        name => rt.id if can(regex("^${env_name}-", name))
      }
    } if length(var.secondary_subnets) > 0
  }
}

output "network_acls_by_env" {
  description = "Network ACLs by environment"
  value = {
    for env_name, env_config in var.secondary_subnets : env_name => {
      public  = contains(keys(aws_network_acl.public), env_name) ? aws_network_acl.public[env_name].id : null
      private = contains(keys(aws_network_acl.private), env_name) ? aws_network_acl.private[env_name].id : null
    } if length(var.secondary_subnets) > 0
  }
}

output "vpc_endpoints" {
  description = "Array containing the full resource object and attributes for all endpoints created"
  value       = module.vpc_endpoints.endpoints
}

output "vpc_cidrs" {
  description = "List of all CIDR ranges associated with the VPC"
  value       = concat([module.vpc.vpc_cidr_block], local.secondary_ip_ranges)
}

# TODO Come back to this later and augment with the information on the Subnet Ids that have been created. This will consolidate some of the other outputs
output "secondary_subnet_configurations" {
  description = "Echo of the Secondary Range Specs by environment"
  value       = local.secondary_subnet_configurations
}