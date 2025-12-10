data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

locals {

  azs = slice(data.aws_availability_zones.available.names, 0, 3)
  # Split the VPC address space into 4 /18s and take the first 3 for Private Subnets
  private_subnets = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 2, k)]
  # Take the last /18 and subdivide into 8 /21s 
  last_18_range = cidrsubnet(var.vpc_cidr, 2, 3)
  # Take the first 3 for Public Subnets
  public_subnets = [for k, v in local.azs : cidrsubnet(local.last_18_range, 3, k)]

  # Take 4-6 for Services Subnets
  services_subnet_map = var.create_services_subnets ? {
    for k, v in local.azs :
    v => {
      cidr_range = cidrsubnet(local.last_18_range, 3, 3 + k)
    }
  } : {}

  # Take the 7th and split into 4 /23s
  seventh_21_range = cidrsubnet(local.last_18_range, 3, 6)

  # Take first 3 of those for Intra for subnets
  intra_subnets = [for k, v in local.azs : cidrsubnet(local.seventh_21_range, 2, k)]

  # Take the last /23 and divide to 2 /24
  last_23_range = cidrsubnet(local.seventh_21_range, 2, 3)

  # tflint-ignore: terraform_unused_declarations
  spare_24_range  = cidrsubnet(local.last_23_range, 1, 1)
  in_use_24_range = cidrsubnet(local.last_23_range, 1, 0)

  # tflint-ignore: terraform_unused_declarations
  spare_25_range  = cidrsubnet(local.in_use_24_range, 1, 1)
  in_use_25_range = cidrsubnet(local.in_use_24_range, 1, 0)

  # Split the 25 range into 28s and use for the TGW and NW Firewall Ranges. TGW not implemented
  # yet as not yet required
  # tflint-ignore: terraform_unused_declarations
  tgw_subnets = [for k, v in local.azs : cidrsubnet(local.in_use_25_range, 3, k)]

  tgw_subnet_map = var.create_tgw_subnets ? {
    for k, v in local.azs :
    v => {
      cidr_range = ccidrsubnet(local.in_use_25_range, 3, k)
    }
  } : {}

  nw_fw_subnet_map = var.create_nw_firewall_subnets ? {
    for k, v in local.azs :
    v => {
      cidr_range = cidrsubnet(local.in_use_25_range, 3, k + 3)
    }
  } : {}

  # Reserve last /21 for future use
  # tflint-ignore: terraform_unused_declarations
  spare_21_range = cidrsubnet(local.last_18_range, 3, 7)

  default_private_inbound_acl_rule = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 65535
      protocol    = "tcp"
      cidr_block  = var.vpc_cidr
    },
    {
      rule_number = 110
      rule_action = "allow"
      from_port   = 0
      to_port     = 65535
      protocol    = "udp"
      cidr_block  = var.vpc_cidr
    },
  ]

  default_private_outbound_acl_rule = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 65535
      protocol    = "tcp"
      cidr_block  = "0.0.0.0/0"
    },
    {
      rule_number = 110
      rule_action = "allow"
      from_port   = 0
      to_port     = 65535
      protocol    = "udp"
      cidr_block  = "0.0.0.0/0"
    }
  ]

  # AWS Shared Services Zone - not expecting stuff deployed here
  default_services_inbound_acl_rule = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_block  = var.vpc_cidr
    }
  ]

  default_services_outbound_acl_rule = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 1024
      to_port     = 65535
      protocol    = "tcp"
      cidr_block  = var.vpc_cidr
    }
  ]

  # Add secondary CIDR ranges to services subnet ACLs if any exist
  services_inbound_acl_rules_with_secondary = concat(
    local.default_services_inbound_acl_rule,
    [
      for i, cidr_range in local.secondary_ip_ranges : {
        rule_number = 200 + i
        rule_action = "allow"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_block  = cidr_range
      }
    ]
  )

  services_outbound_acl_rules_with_secondary = concat(
    local.default_services_outbound_acl_rule,
    [
      for i, cidr_range in local.secondary_ip_ranges : {
        rule_number = 200 + i
        rule_action = "allow"
        from_port   = 1024
        to_port     = 65535
        protocol    = "tcp"
        cidr_block  = cidr_range
      }
    ]
  )

  private_inbound_acl_rules  = length(var.private_inbound_acl_rules) == 0 ? local.default_private_inbound_acl_rule : var.private_inbound_acl_rules
  private_outbound_acl_rules = length(var.private_outbound_acl_rules) == 0 ? local.default_private_outbound_acl_rule : var.private_outbound_acl_rules

  # Use the defaults if the user hasn't supplied an input
  services_inbound_acl_rules  = var.create_services_subnets == false ? [] : (length(var.services_inbound_acl_rules) == 0 ? local.services_inbound_acl_rules_with_secondary : var.services_inbound_acl_rules)
  services_outbound_acl_rules = var.create_services_subnets == false ? [] : (length(var.services_outbound_acl_rules) == 0 ? local.services_outbound_acl_rules_with_secondary : var.services_outbound_acl_rules)

  route_tables_for_endpoints = var.create_intra_subnets == false ? concat(module.vpc.private_route_table_ids, module.vpc.public_route_table_ids) : concat(module.vpc.private_route_table_ids, module.vpc.public_route_table_ids, module.vpc.intra_route_table_ids)
  rt_endpoints               = concat(local.route_tables_for_endpoints, [for rt in aws_route_table.private : rt.id], [for rt in aws_route_table.public : rt.id], [aws_route_table.services[0].id])

  # Gateway endpoints are free so always include these
  gateway_vpc_endpoints = {
    s3 = {
      service         = "s3"
      route_table_ids = local.rt_endpoints
      service_type    = "Gateway"
      tags            = { Name = "s3-vpc-endpoint" }
    },
    dynamodb = {
      service         = "dynamodb"
      route_table_ids = local.rt_endpoints
      service_type    = "Gateway"
      tags            = { Name = "dynamodb-vpc-endpoint" }
    }
  }

  dynamic_vpc_endpoints = {
    for service_name in var.endpoint_services : replace(service_name, ".", "-") => {
      service             = service_name
      private_dns_enabled = true
      subnet_ids          = var.create_services_subnets ? aws_subnet.service_subnet[*].id : module.vpc.private_subnets
      tags                = { Name = "${replace(service_name, ".", "-")}-vpc-endpoint" }
    }
  }

  vpc_endpoints = merge(local.gateway_vpc_endpoints, local.dynamic_vpc_endpoints)

  # END OF STANDARD VPC LOGIC.
  # These variables are dedicated to calculating additional shared subnets for VPC sharing
  # The VPC module needs a list of secondary CIDR ranges so collect the ranges from the environments specified
  secondary_ip_ranges = length(var.secondary_subnets) > 0 ? distinct([
    for env_name, env_config in var.secondary_subnets : env_config.cidr_range
  ]) : []

  # Process secondary subnets by environment
  # Build a map of environment names to their required configs, calcuting the CIDR ranges required
  # for the configured subnets
  secondary_subnet_configurations = {
    for env_name, env_config in var.secondary_subnets : env_name => {
      cidr_range     = env_config.cidr_range
      create_public  = env_config.create_public
      create_private = env_config.create_private

      # Calculate subnet ranges
      # Split the network range into 4 and take the first 3 for the k for private subnet ranges
      # k will be 3 since we use 3 AZs
      private_subnet_cidrs = env_config.create_private ? [
        for k, v in local.azs : cidrsubnet(env_config.cidr_range, 2, k)
      ] : []

      # Take the 4th CIDR range from above and split this into 8, taking the first k (3) for the
      # public subnet ranges
      public_subnet_cidrs = env_config.create_public ? [
        for k, v in local.azs : cidrsubnet(cidrsubnet(env_config.cidr_range, 2, 3), 3, k)
      ] : []

      # Other configurations passed through
      public_subnet_tags               = env_config.public_subnet_tags
      private_subnet_tags              = env_config.private_subnet_tags
      public_nacl_rules                = env_config.public_nacl_rules
      private_nacl_rules               = env_config.private_nacl_rules
      create_custom_route_tables       = env_config.create_custom_route_tables
      create_igw_route                 = env_config.create_igw_route
      create_nat_routes                = env_config.create_nat_routes
      public_routes                    = env_config.public_routes
      private_routes                   = env_config.private_routes
      shared_public_subnet_principals  = env_config.shared_public_subnet_principals
      shared_private_subnet_principals = env_config.shared_private_subnet_principals
    }
  }

  # Flatten secondary subnets to create public subnets where specified. This collects all the subnets that
  # need to be created and allocates them an AZ
  secondary_public_subnets = flatten([
    for env_name, env_config in local.secondary_subnet_configurations : [
      for az_index, az in local.azs : {
        name             = "${env_name}-public-${az}"
        cidr_block       = env_config.public_subnet_cidrs[az_index]
        az               = az
        env              = env_name
        tags             = env_config.public_subnet_tags
        nacl_rules       = env_config.public_nacl_rules
        routes           = env_config.public_routes
        create_rt        = env_config.create_custom_route_tables
        create_igw_route = env_config.create_igw_route
      } if env_config.create_public
    ]
  ])

  # Flatten secondary subnets to create private subnets where specified. This collects all the subnets that
  # need to be created and allocates them an AZ
  secondary_private_subnets = flatten([
    for env_name, env_config in local.secondary_subnet_configurations : [
      for az_index, az in local.azs : {
        name              = "${env_name}-private-${az}"
        cidr_block        = env_config.private_subnet_cidrs[az_index]
        az                = az
        env               = env_name
        tags              = env_config.private_subnet_tags
        nacl_rules        = env_config.private_nacl_rules
        routes            = env_config.private_routes
        create_rt         = env_config.create_custom_route_tables
        create_nat_routes = env_config.create_nat_routes
      } if env_config.create_private
    ]
  ])

  # Group subnets by environment for route table creation
  secondary_subnet_environments = {
    for env_name, env_config in var.secondary_subnets : env_name => {
      public                     = [for subnet in local.secondary_public_subnets : subnet if subnet.env == env_name]
      private                    = [for subnet in local.secondary_private_subnets : subnet if subnet.env == env_name]
      create_custom_route_tables = env_config.create_custom_route_tables
      create_igw_route           = env_config.create_igw_route
      create_nat_routes          = env_config.create_nat_routes
      public_routes              = env_config.public_routes
      private_routes             = env_config.private_routes
    }
  }

  # Flatten public routes for easier handling
  flattened_public_routes = flatten([
    for env, config in local.secondary_subnet_environments : [
      for route_idx, route in config.public_routes : {
        env       = env
        route     = route
        route_idx = route_idx
        id        = "${env}-public-${route_idx}"
      }
    ] if length(config.public_routes) > 0
  ])

  # Flatten private routes for easier handling
  flattened_private_routes = flatten([
    for name, subnet in local.secondary_private_subnets_map : [
      for route_idx, route in subnet.routes : {
        subnet_name = name
        route       = route
        id          = "${name}-${route_idx}"
      }
    ] if length(subnet.routes) > 0
  ])


  # Create maps for easy lookup
  secondary_public_subnets_map  = { for subnet in local.secondary_public_subnets : subnet.name => subnet }
  secondary_private_subnets_map = { for subnet in local.secondary_private_subnets : subnet.name => subnet }

  # Map of environments with create_public = true and specified public_nacl_rules
  public_nacl_rules_map = {
    for env_name, env_config in var.secondary_subnets :
    env_name => env_config.public_nacl_rules
    if env_config.create_public == true && length(env_config.public_nacl_rules) > 0
  }

  # Map of environments with create_private = true and specified private_nacl_rules
  private_nacl_rules_map = {
    for env_name, env_config in var.secondary_subnets :
    env_name => env_config.private_nacl_rules
    if env_config.create_private == true && length(env_config.private_nacl_rules) > 0
  }
}

# Use the AWS Terraform VPC module for as much heavy lifting as possible
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0"

  name            = var.name
  cidr            = var.vpc_cidr
  private_subnets = local.private_subnets
  public_subnets  = var.create_public_subnets ? local.public_subnets : []
  intra_subnets   = var.create_intra_subnets ? local.intra_subnets : []

  azs = local.azs

  create_igw = var.create_igw

  enable_nat_gateway                   = var.enable_nat_gateway
  single_nat_gateway                   = var.single_nat_gateway
  one_nat_gateway_per_az               = !var.single_nat_gateway
  enable_flow_log                      = var.enable_flow_log
  create_flow_log_cloudwatch_log_group = var.create_flow_log_cloudwatch_log_group
  create_flow_log_cloudwatch_iam_role  = var.create_flow_log_cloudwatch_iam_role

  public_dedicated_network_acl = var.public_dedicated_network_acl
  public_outbound_acl_rules    = var.public_outbound_acl_rules
  public_inbound_acl_rules     = var.public_inbound_acl_rules

  private_inbound_acl_rules     = local.private_inbound_acl_rules
  private_outbound_acl_rules    = local.private_outbound_acl_rules
  private_dedicated_network_acl = var.private_dedicated_network_acl

  secondary_cidr_blocks = local.secondary_ip_ranges

  public_subnet_tags  = var.public_subnet_tags
  private_subnet_tags = var.private_subnet_tags
}

# Create a local with known keys based on the number of private subnets
locals {
  private_subnet_map = {
    for idx in range(length(module.vpc.private_subnets)) : "subnet_${idx}" => module.vpc.private_subnets[idx]
  }

  public_subnet_map = {
    for idx in range(length(module.vpc.public_subnets)) : "subnet_${idx}" => module.vpc.public_subnets[idx]
  }
}

# Create resource shares with known keys
resource "aws_ram_resource_share" "core_private_subnet_share" {
  for_each = local.private_subnet_map

  name                      = "private-subnet-share-${each.key}"
  allow_external_principals = false
}

# Create resource shares with known keys
resource "aws_ram_resource_share" "core_public_subnet_share" {
  for_each = local.public_subnet_map

  name                      = "public-subnet-share-${each.key}"
  allow_external_principals = false
}

# Associate the subnet resources after they're created
resource "aws_ram_resource_association" "core_private_subnet_association" {
  for_each = local.private_subnet_map

  resource_share_arn = aws_ram_resource_share.core_private_subnet_share[each.key].arn
  resource_arn       = "arn:aws:ec2:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:subnet/${each.value}"
}

# Associate the subnet resources after they're created
resource "aws_ram_resource_association" "core_public_subnet_association" {
  for_each = local.public_subnet_map

  resource_share_arn = aws_ram_resource_share.core_public_subnet_share[each.key].arn
  resource_arn       = "arn:aws:ec2:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:subnet/${each.value}"
}

# Create principal associations with known keys
resource "aws_ram_principal_association" "principal_associations" {
  for_each = {
    for pair in setproduct(keys(local.private_subnet_map), var.share_private_subnets_principals) :
    "${pair[0]}_principal_${pair[1]}" => {
      subnet_key = pair[0]
      principal  = pair[1]
    }
  }

  principal          = each.value.principal
  resource_share_arn = aws_ram_resource_share.core_private_subnet_share[each.value.subnet_key].arn
}

# Create principal associations with known keys
resource "aws_ram_principal_association" "public_principal_associations" {
  for_each = {
    for pair in setproduct(keys(local.public_subnet_map), var.share_public_subnets_principals) :
    "${pair[0]}_principal_${pair[1]}" => {
      subnet_key = pair[0]
      principal  = pair[1]
    }
  }

  principal          = each.value.principal
  resource_share_arn = aws_ram_resource_share.core_public_subnet_share[each.value.subnet_key].arn
}