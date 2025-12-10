# Create the secondary public subnets
resource "aws_subnet" "secondary_public" {
  for_each = local.secondary_public_subnets_map

  vpc_id                  = module.vpc.vpc_id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.az
  map_public_ip_on_launch = true

  tags = merge(
    {
      Name        = each.value.name
      Environment = each.value.env
      Tier        = "Public"
    },
    each.value.tags
  )
}

# Create the secondary private subnets
resource "aws_subnet" "secondary_private" {
  for_each = local.secondary_private_subnets_map

  vpc_id            = module.vpc.vpc_id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.az

  tags = merge(
    {
      Name        = each.value.name
      Environment = each.value.env
      Tier        = "Private"
    },
    each.value.tags
  )
}

# Create NACLs for public subnets for each environment. Key these on env so was can retrieve later
resource "aws_network_acl" "public" {
  # for_each = { for env in local.environments_with_nacls : env => env }
  for_each = local.public_nacl_rules_map

  vpc_id = module.vpc.vpc_id

  tags = merge(
    # Find the first public subnet for this environment and get its tags
    try(
      [for subnet in local.secondary_public_subnets : subnet.tags if subnet.env == each.key][0],
      {} # Default empty map if no matching subnets found
    ),
    {
      Name        = "${each.key}-public-nacl"
      Environment = each.key
    }
  )
}

# Create NACLs for private subnets for each environment. Key these on env so was can retrieve later
resource "aws_network_acl" "private" {
  # for_each = { for env in local.environments_with_nacls : env => env }
  for_each = local.private_nacl_rules_map

  vpc_id = module.vpc.vpc_id

  tags = merge(
    # Find the first private subnet for this environment and get its tags
    try(
      [for subnet in local.secondary_private_subnets : subnet.tags if subnet.env == each.key][0],
      {} # Default empty map if no matching subnets found
    ),
    {
      Name        = "${each.key}-private-nacl"
      Environment = each.key
    }
  )
}

# Associate public subnets with their NACLs
resource "aws_network_acl_association" "public" {
  # Go through all the public subnets and collect them if they are associated with an env
  # that needs NACLs applying to its public subnets
  for_each = {
    for name, subnet in local.secondary_public_subnets_map :
    name => subnet if contains(keys(local.public_nacl_rules_map), subnet.env)
  }

  network_acl_id = aws_network_acl.public[each.value.env].id
  subnet_id      = aws_subnet.secondary_public[each.key].id
}

# Associate private subnets with their NACLs
resource "aws_network_acl_association" "private" {
  # Go through all the private subnets and collect them if they are associated with an env
  # that needs NACLs applying to its public subnets
  for_each = {
    for name, subnet in local.secondary_private_subnets_map :
    name => subnet if contains(keys(local.private_nacl_rules_map), subnet.env)
  }

  network_acl_id = aws_network_acl.private[each.value.env].id
  subnet_id      = aws_subnet.secondary_private[each.key].id
}

resource "aws_network_acl_rule" "public" {
  for_each = {
    for rule_data in flatten([
      for env_name, nacl_rules in local.public_nacl_rules_map : [
        for rule_idx, rule in nacl_rules : {
          env  = env_name
          rule = rule
          id   = "${env_name}-${rule.rule_number}-${rule.egress ? "egress" : "ingress"}"
        }
      ]
    ]) : rule_data.id => rule_data
  }

  network_acl_id = aws_network_acl.public[each.value.env].id
  rule_number    = each.value.rule.rule_number
  egress         = each.value.rule.egress
  protocol       = each.value.rule.protocol
  rule_action    = each.value.rule.rule_action
  cidr_block     = each.value.rule.cidr_block
  from_port      = each.value.rule.from_port
  to_port        = each.value.rule.to_port
}

resource "aws_network_acl_rule" "private" {
  for_each = {
    for rule_data in flatten([
      for env_name, nacl_rules in local.private_nacl_rules_map : [
        for rule_idx, rule in nacl_rules : {
          env  = env_name
          rule = rule
          id   = "${env_name}-${rule.rule_number}-${rule.egress ? "egress" : "ingress"}"
        }
      ]
    ]) : rule_data.id => rule_data
  }

  network_acl_id = aws_network_acl.private[each.value.env].id
  rule_number    = each.value.rule.rule_number
  egress         = each.value.rule.egress
  protocol       = each.value.rule.protocol
  rule_action    = each.value.rule.rule_action
  cidr_block     = each.value.rule.cidr_block
  from_port      = each.value.rule.from_port
  to_port        = each.value.rule.to_port
}

# Create route tables for public subnets - one per environment
resource "aws_route_table" "public" {
  for_each = {
    # Collect a map of envs to subnets for those with public subnets that have
    # custom routes, a specification to create a route to the IGW or create a custom route table
    for env, subnets in local.secondary_subnet_environments :
    env => subnets if length(subnets.public) > 0 &&
    (subnets.create_custom_route_tables || subnets.create_igw_route || length(subnets.public_routes) > 0)
  }

  vpc_id = module.vpc.vpc_id

  tags = {
    Name        = "${each.key}-public-rt"
    Environment = each.key
    Tier        = "Public"
  }
}

# # Associate route tables with public subnets
resource "aws_route_table_association" "public" {
  for_each = {
    for name, subnet in local.secondary_public_subnets_map :
    name => subnet if subnet.create_rt || subnet.create_igw_route || length(subnet.routes) > 0
  }

  subnet_id      = aws_subnet.secondary_public[each.key].id
  route_table_id = aws_route_table.public[each.value.env].id
}

# Create IGW route for public subnets if specified
resource "aws_route" "public_igw" {
  for_each = {
    for env, subnets in local.secondary_subnet_environments :
    env => subnets if length(subnets.public) > 0 && subnets.create_igw_route && var.create_igw
  }

  route_table_id         = aws_route_table.public[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = module.vpc.igw_id
}

locals {
  subnet_sharing_config = {
    for env_name, env_config in var.secondary_subnets : env_name => {
      # Basic sharing configuration
      has_shared_public_principals  = length(env_config.shared_public_subnet_principals) > 0
      has_shared_private_principals = length(env_config.shared_private_subnet_principals) > 0
      public_principals             = env_config.shared_public_subnet_principals
      private_principals            = env_config.shared_private_subnet_principals

      # The public subnets for this environment
      public_subnets = {
        for name, subnet in aws_subnet.secondary_public :
        name => subnet.id if can(regex("^${env_name}-", name))
      }

      # The private subnets for this environment
      private_subnets = {
        for name, subnet in aws_subnet.secondary_private :
        name => subnet.id if can(regex("^${env_name}-", name))
      }
    }
  }
}

resource "aws_ram_resource_share" "public_subnet_share" {
  for_each = {
    for env, config in local.subnet_sharing_config : env => config
    if config.has_shared_public_principals
  }

  name                      = "${each.key}-public-subnet-share"
  allow_external_principals = false
}

resource "aws_ram_resource_share" "private_subnet_share" {
  for_each = {
    for env, config in local.subnet_sharing_config : env => config
    if config.has_shared_private_principals
  }

  name                      = "${each.key}-private-subnet-share"
  allow_external_principals = false
}


# Resource associations for all public subnets that need to be shared
resource "aws_ram_resource_association" "public_subnet_share" {
  for_each = {
    for item in flatten([
      for env, config in local.subnet_sharing_config : [
        for subnet_name, subnet_id in config.public_subnets : {
          env_key    = env
          subnet_key = subnet_name
          subnet_id  = subnet_id
        }
      ] if config.has_shared_public_principals
    ]) : "${item.env_key}-${item.subnet_key}" => item
  }

  resource_share_arn = aws_ram_resource_share.public_subnet_share[each.value.env_key].arn
  resource_arn       = "arn:aws:ec2:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:subnet/${each.value.subnet_id}"
}

# Resource associations for all public subnets that need to be shared
resource "aws_ram_resource_association" "private_subnet_share" {
  for_each = {
    for item in flatten([
      for env, config in local.subnet_sharing_config : [
        for subnet_name, subnet_id in config.private_subnets : {
          env_key    = env
          subnet_key = subnet_name
          subnet_id  = subnet_id
        }
      ] if config.has_shared_private_principals
    ]) : "${item.env_key}-${item.subnet_key}" => item
  }

  resource_share_arn = aws_ram_resource_share.private_subnet_share[each.value.env_key].arn
  resource_arn       = "arn:aws:ec2:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:subnet/${each.value.subnet_id}"
}

# Principal associations for public subnets
resource "aws_ram_principal_association" "public_subnet_principals" {
  for_each = {
    for item in flatten([
      for env, config in local.subnet_sharing_config : [
        for principal in config.public_principals : {
          env_key   = env
          principal = principal
        }
      ] if config.has_shared_public_principals
    ]) : "${item.env_key}-${item.principal}" => item
  }

  resource_share_arn = aws_ram_resource_share.public_subnet_share[each.value.env_key].arn
  principal          = each.value.principal
}

# Principal associations for public subnets
resource "aws_ram_principal_association" "private_subnet_principals" {
  for_each = {
    for item in flatten([
      for env, config in local.subnet_sharing_config : [
        for principal in config.private_principals : {
          env_key   = env
          principal = principal
        }
      ] if config.has_shared_private_principals
    ]) : "${item.env_key}-${item.principal}" => item
  }

  resource_share_arn = aws_ram_resource_share.private_subnet_share[each.value.env_key].arn
  principal          = each.value.principal
}

# Create additional routes for public subnets
resource "aws_route" "public_additional" {
  for_each = {
    for key, route in local.flattened_public_routes : key => route
  }

  route_table_id         = aws_route_table.public[each.value.env].id
  destination_cidr_block = each.value.route.cidr_block
  gateway_id             = each.value.route.gateway_id
  nat_gateway_id         = each.value.route.nat_gateway_id
  vpc_endpoint_id        = each.value.route.vpc_endpoint_id
}

locals {
  private_subnets_needing_route_tables = {
    for name, subnet in local.secondary_private_subnets_map :
    name => subnet
    if subnet.create_rt || subnet.create_nat_routes || length(subnet.routes) > 0
  }
}

# # Create private route tables - one per subnet for AZ-specific routes
resource "aws_route_table" "private" {
  for_each = local.private_subnets_needing_route_tables

  vpc_id = module.vpc.vpc_id

  tags = merge(
    try(each.value.tags, {}),
    {
      Name        = "${each.key}-rt"
      Environment = each.value.env
      Tier        = "Private"
      AZ          = try(each.value.az, null)
    }
  )
}

# # Associate route tables with private subnets
resource "aws_route_table_association" "private" {
  for_each = {
    for name, subnet in local.secondary_private_subnets_map :
    name => subnet if subnet.create_rt || subnet.create_nat_routes || length(subnet.routes) > 0
  }

  subnet_id      = aws_subnet.secondary_private[each.key].id
  route_table_id = aws_route_table.private[each.key].id
}

# Build a map of NAT GW to AZ
data "aws_nat_gateway" "nat_gateways" {
  for_each = var.enable_nat_gateway ? {
    for idx, az in local.azs : az => az if !var.single_nat_gateway || idx == 0
  } : {}

  filter {
    name   = "vpc-id"
    values = [module.vpc.vpc_id]
  }

  filter {
    name   = "subnet-id"
    values = [module.vpc.public_subnets[var.single_nat_gateway ? 0 : index(local.azs, each.key)]]
  }

  filter {
    name   = "state"
    values = ["available"]
  }

  depends_on = [module.vpc]
}

# Create NAT routes for private subnets when specified
resource "aws_route" "private_nat" {
  for_each = {
    for name, subnet in local.secondary_private_subnets_map :
    name => subnet if subnet.create_nat_routes && var.enable_nat_gateway
  }

  route_table_id         = aws_route_table.private[each.key].id
  destination_cidr_block = "0.0.0.0/0"

  nat_gateway_id = var.single_nat_gateway ? module.vpc.natgw_ids[0] : (
    # Look up the NAT gateway in the same AZ as the subnet
    try(data.aws_nat_gateway.nat_gateways[each.value.az].id, module.vpc.natgw_ids[0])
  )
}

# Create additional routes for private subnets
resource "aws_route" "private_additional" {
  for_each = {
    for key, route in local.flattened_private_routes : key => route
  }

  route_table_id         = aws_route_table.private[each.value.subnet_name].id
  destination_cidr_block = each.value.route.cidr_block
  gateway_id             = each.value.route.gateway_id
  nat_gateway_id         = each.value.route.nat_gateway_id
  vpc_endpoint_id        = each.value.route.vpc_endpoint_id
}
