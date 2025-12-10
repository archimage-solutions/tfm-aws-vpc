variable "name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
}

variable "vpc_cidr" {
  description = "The IPv4 CIDR block for the VPC. This forms the core network"
  type        = string
}

variable "create_public_subnets" {
  type        = bool
  default     = true
  description = "Determines whether subnets for public internet facing services is created"
}

variable "create_intra_subnets" {
  type        = bool
  default     = false
  description = "Determines whether intra subnets are created - these are commonly used for EKS Control Plane"
}

variable "create_services_subnets" {
  type        = bool
  default     = true
  description = "Determines whether subnets for hosting VPC endpoint services and AWS managed services are created"
}

# See https://docs.aws.amazon.com/vpc/latest/tgw/tgw-best-design-practices.html
variable "create_tgw_subnets" {
  type        = bool
  default     = false
  description = "Determines whether subnets for Transit Gateway Attachments are created"
}

variable "create_nw_firewall_subnets" {
  type        = bool
  default     = false
  description = "Determines whether subnets for AWS Network Firewall are created"
}

variable "create_igw" {
  type        = bool
  default     = true
  description = "Determines whether to create an IGW"
}

variable "enable_nat_gateway" {
  type        = bool
  default     = true
  description = "Determines whether to enable IPv4 NAT"
}

variable "single_nat_gateway" {
  type        = bool
  default     = true
  description = "Determines whether to provision IPv4 NAT in each AZ for HA"
}

variable "private_dedicated_network_acl" {
  type        = bool
  default     = true
  description = "Whether to enable dedicated network ACLs on private core subnets"
}

variable "public_dedicated_network_acl" {
  type        = bool
  default     = false
  description = "Whether to enable dedicated network ACLs on public core subnets"
}

variable "enable_flow_log" {
  type        = bool
  default     = true
  description = "Determines whether VPC flow logs are enabled"
}

variable "create_flow_log_cloudwatch_log_group" {
  type        = bool
  default     = true
  description = "Determines whether VPC flow logs group is created or injected"
}

variable "create_flow_log_cloudwatch_iam_role" {
  type        = bool
  default     = true
  description = "Determines whether cw flow logs role is created or injected"
}

variable "public_inbound_acl_rules" {
  description = "Public subnets inbound network ACLs"
  type        = list(any)
  default = [
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
    },
  ]
}

variable "public_outbound_acl_rules" {
  description = "Public subnets outbound network ACLs"
  type        = list(any)
  default = [
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
    },
  ]
}

# This pattern allows the user to specify their own ACL, otherwise one is created in the interpolated defaults
variable "private_inbound_acl_rules" {
  description = "Private subnets outbound network ACLs"
  type        = list(any)
  default     = []
}

# This pattern allows the user to specify their own ACL, otherwise one is created in the interpolated defaults
variable "services_inbound_acl_rules" {
  description = "Services subnets inbound network ACLs"
  type        = list(any)
  default     = []
}

# This pattern allows the user to specify their own ACL, otherwise one is created in the interpolated defaults
variable "services_outbound_acl_rules" {
  description = "Services subnets inbound network ACLs"
  type        = list(any)
  default     = []
}

# This pattern allows the user to specify additional vpc endpoint services. The exhaustive possible list is here
# https://docs.aws.amazon.com/vpc/latest/privatelink/aws-services-privatelink-support.html
# Note only the part after the region needs to be specified.
# Examples com.amazonaws.region.autoscaling => autoscaling
# com.amazonaws.region.ecr.api => ecr.api
variable "endpoint_services" {
  description = "String list of VPC endpoints to add to the VPC in short form e.g. 'ecr.api'"
  type        = list(string)
  default     = []
}

# This pattern allows the user to specify their own ACL, otherwise one is created in the interpolated defaults
variable "private_outbound_acl_rules" {
  description = "Private subnets outbound network ACLs"
  type        = list(any)
  default     = []
}

variable "public_subnet_tags" {
  description = "Tags to apply to public subnets"
  type        = map(string)
  default     = {}
}

variable "private_subnet_tags" {
  description = "Tags to apply to private subnets"
  type        = map(string)
  default     = {}
}

variable "share_private_subnets_principals" {
  description = "Any principals with which the core private subnets are to be shared"
  type        = list(string)
  default     = []
}

variable "share_public_subnets_principals" {
  description = "Any principals with which the core public subnets are to be shared"
  type        = list(string)
  default     = []
}

variable "secondary_subnets" {
  description = "Map of secondary subnet configurations by environment"
  type = map(object({
    cidr_range          = string
    create_public       = bool
    create_private      = bool
    public_subnet_tags  = optional(map(string), {})
    private_subnet_tags = optional(map(string), {})
    public_nacl_rules = optional(list(object({
      rule_number = number
      egress      = bool
      protocol    = string
      rule_action = string
      cidr_block  = string
      from_port   = number
      to_port     = number
    })), [])
    private_nacl_rules = optional(list(object({
      rule_number = number
      egress      = bool
      protocol    = string
      rule_action = string
      cidr_block  = string
      from_port   = number
      to_port     = number
    })), [])
    create_custom_route_tables = optional(bool, false)
    create_igw_route           = optional(bool, true)
    create_nat_routes          = optional(bool, false)
    public_routes = optional(list(object({
      cidr_block      = string
      gateway_id      = optional(string)
      nat_gateway_id  = optional(string)
      vpc_endpoint_id = optional(string)
    })), [])
    private_routes = optional(list(object({
      cidr_block      = string
      gateway_id      = optional(string)
      nat_gateway_id  = optional(string)
      vpc_endpoint_id = optional(string)
    })), [])
    shared_public_subnet_principals  = optional(list(string), [])
    shared_private_subnet_principals = optional(list(string), [])
  }))
  default = {}
}