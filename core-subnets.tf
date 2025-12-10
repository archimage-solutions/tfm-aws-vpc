#--------------------------------------------------------------
# Subnets
#--------------------------------------------------------------

resource "aws_subnet" "service_subnet" {
  for_each = local.services_subnet_map

  availability_zone = each.key

  vpc_id     = module.vpc.vpc_id
  cidr_block = each.value.cidr_range

  tags = {
    Name = "${var.name}-endpoint-services-${each.key}"
  }
}

resource "aws_subnet" "tgw_subnet" {
  for_each = local.tgw_subnet_map

  availability_zone = each.key

  vpc_id     = module.vpc.vpc_id
  cidr_block = each.value.cidr_range

  tags = {
    Name = "${var.name}-tgw-subnet-${each.key}"
  }
}

resource "aws_subnet" "nw_fw_subnet" {
  for_each = local.nw_fw_subnet_map

  availability_zone = each.key

  vpc_id     = module.vpc.vpc_id
  cidr_block = each.value.cidr_range

  tags = {
    Name = "${var.name}-nw-firewall-subnet-${each.key}"
  }
}


#--------------------------------------------------------------
# Routes
#--------------------------------------------------------------
resource "aws_route_table" "services" {
  count = var.create_services_subnets ? 1 : 0

  vpc_id = module.vpc.vpc_id

  tags = { "Name" = "${var.name}-services" }

}

resource "aws_route_table_association" "services" {
  for_each = aws_subnet.service_subnet

  subnet_id = each.value.id

  route_table_id = aws_route_table.services[0].id
}

resource "aws_route_table" "tgw" {
  count = var.create_tgw_subnets ? 1 : 0

  vpc_id = module.vpc.vpc_id

  tags = { "Name" = "${var.name}-tgw" }
}

resource "aws_route_table_association" "tgw" {
  for_each = aws_subnet.tgw_subnet

  subnet_id = each.value.id

  route_table_id = aws_route_table.tgw[0].id
}

resource "aws_route_table" "nw_fw" {
  count = var.create_nw_firewall_subnets ? 1 : 0

  vpc_id = module.vpc.vpc_id

  tags = { "Name" = "${var.name}-nw-fw" }
}

resource "aws_route_table_association" "nw_fw" {
  for_each = aws_subnet.nw_fw_subnet

  subnet_id      = each.value.id
  route_table_id = aws_route_table.nw_fw[0].id
}

#--------------------------------------------------------------
# Network ACLs
#--------------------------------------------------------------
resource "aws_network_acl" "public_network_acl" {
  count = var.create_public_subnets ? 1 : 0

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets

  tags = { "Name" = "${var.name}-public-subnet-acl" }
}

resource "aws_network_acl_rule" "public_inbound_network_acl_rule" {
  for_each = {
    for acl in var.public_inbound_acl_rules : acl.rule_number => acl
  }

  network_acl_id = aws_network_acl.public_network_acl[0].id

  egress          = false
  rule_number     = each.value.rule_number
  rule_action     = each.value.rule_action
  from_port       = lookup(each.value, "from_port", null)
  to_port         = lookup(each.value, "to_port", null)
  icmp_code       = lookup(each.value, "icmp_code", null)
  icmp_type       = lookup(each.value, "icmp_type", null)
  protocol        = each.value.protocol
  cidr_block      = lookup(each.value, "cidr_block", null)
  ipv6_cidr_block = lookup(each.value, "ipv6_cidr_block", null)
}

resource "aws_network_acl_rule" "public_outbound_network_acl_rule" {
  for_each = {
    for acl in var.public_inbound_acl_rules : acl.rule_number => acl
  }

  network_acl_id = aws_network_acl.public_network_acl[0].id

  egress          = true
  rule_number     = each.value.rule_number
  rule_action     = each.value.rule_action
  from_port       = lookup(each.value, "from_port", null)
  to_port         = lookup(each.value, "to_port", null)
  icmp_code       = lookup(each.value, "icmp_code", null)
  icmp_type       = lookup(each.value, "icmp_type", null)
  protocol        = each.value.protocol
  cidr_block      = lookup(each.value, "cidr_block", null)
  ipv6_cidr_block = lookup(each.value, "ipv6_cidr_block", null)
}

resource "aws_network_acl" "private_network_acl" {
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  tags = { "Name" = "${var.name}-private-subnet-acl" }
}

resource "aws_network_acl_rule" "private_inbound_network_acl_rule" {
  for_each = {
    for acl in var.private_inbound_acl_rules : acl.rule_number => acl
  }

  network_acl_id = aws_network_acl.private_network_acl.id

  egress          = false
  rule_number     = each.value.rule_number
  rule_action     = each.value.rule_action
  from_port       = lookup(each.value, "from_port", null)
  to_port         = lookup(each.value, "to_port", null)
  icmp_code       = lookup(each.value, "icmp_code", null)
  icmp_type       = lookup(each.value, "icmp_type", null)
  protocol        = each.value.protocol
  cidr_block      = lookup(each.value, "cidr_block", null)
  ipv6_cidr_block = lookup(each.value, "ipv6_cidr_block", null)
}

resource "aws_network_acl_rule" "private_outbound_network_acl_rule" {
  for_each = {
    for acl in var.public_inbound_acl_rules : acl.rule_number => acl
  }

  network_acl_id = aws_network_acl.private_network_acl.id

  egress          = true
  rule_number     = each.value.rule_number
  rule_action     = each.value.rule_action
  from_port       = lookup(each.value, "from_port", null)
  to_port         = lookup(each.value, "to_port", null)
  icmp_code       = lookup(each.value, "icmp_code", null)
  icmp_type       = lookup(each.value, "icmp_type", null)
  protocol        = each.value.protocol
  cidr_block      = lookup(each.value, "cidr_block", null)
  ipv6_cidr_block = lookup(each.value, "ipv6_cidr_block", null)
}

resource "aws_network_acl" "services_network_acl" {
  count = var.create_services_subnets ? 1 : 0

  vpc_id     = module.vpc.vpc_id
  subnet_ids = [for subnet in aws_subnet.service_subnet : subnet.id]

  tags = { "Name" = "${var.name}-services-subnet-acl" }
}

resource "aws_network_acl_rule" "services_outbound_network_acl_rule" {
  for_each = {
    for acl in local.services_outbound_acl_rules : acl.rule_number => acl
  }

  network_acl_id = aws_network_acl.services_network_acl[0].id

  egress          = true
  rule_number     = each.value.rule_number
  rule_action     = each.value.rule_action
  from_port       = lookup(each.value, "from_port", null)
  to_port         = lookup(each.value, "to_port", null)
  icmp_code       = lookup(each.value, "icmp_code", null)
  icmp_type       = lookup(each.value, "icmp_type", null)
  protocol        = each.value.protocol
  cidr_block      = lookup(each.value, "cidr_block", null)
  ipv6_cidr_block = lookup(each.value, "ipv6_cidr_block", null)
}

resource "aws_network_acl_rule" "services_inbound_network_acl_rule" {
  for_each = {
    for acl in local.services_inbound_acl_rules : acl.rule_number => acl
  }

  network_acl_id = aws_network_acl.services_network_acl[0].id

  egress          = false
  rule_number     = each.value.rule_number
  rule_action     = each.value.rule_action
  from_port       = lookup(each.value, "from_port", null)
  to_port         = lookup(each.value, "to_port", null)
  icmp_code       = lookup(each.value, "icmp_code", null)
  icmp_type       = lookup(each.value, "icmp_type", null)
  protocol        = each.value.protocol
  cidr_block      = lookup(each.value, "cidr_block", null)
  ipv6_cidr_block = lookup(each.value, "ipv6_cidr_block", null)
}