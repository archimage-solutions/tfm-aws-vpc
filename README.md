# AWS VPC Module
This module supports subnet sharing across and AWS organization.


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.94.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | ~> 6.0 |
| <a name="module_vpc_endpoints"></a> [vpc\_endpoints](#module\_vpc\_endpoints) | terraform-aws-modules/vpc/aws//modules/vpc-endpoints | ~> 6.0 |

## Resources

| Name | Type |
|------|------|
| [aws_network_acl.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl) | resource |
| [aws_network_acl.private_network_acl](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl) | resource |
| [aws_network_acl.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl) | resource |
| [aws_network_acl.public_network_acl](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl) | resource |
| [aws_network_acl.services_network_acl](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl) | resource |
| [aws_network_acl_association.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_association) | resource |
| [aws_network_acl_association.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_association) | resource |
| [aws_network_acl_rule.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.private_inbound_network_acl_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.private_outbound_network_acl_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.public_inbound_network_acl_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.public_outbound_network_acl_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.services_inbound_network_acl_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.services_outbound_network_acl_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_ram_principal_association.principal_associations](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_principal_association) | resource |
| [aws_ram_principal_association.private_subnet_principals](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_principal_association) | resource |
| [aws_ram_principal_association.public_principal_associations](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_principal_association) | resource |
| [aws_ram_principal_association.public_subnet_principals](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_principal_association) | resource |
| [aws_ram_resource_association.core_private_subnet_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_resource_association) | resource |
| [aws_ram_resource_association.core_public_subnet_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_resource_association) | resource |
| [aws_ram_resource_association.private_subnet_share](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_resource_association) | resource |
| [aws_ram_resource_association.public_subnet_share](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_resource_association) | resource |
| [aws_ram_resource_share.core_private_subnet_share](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_resource_share) | resource |
| [aws_ram_resource_share.core_public_subnet_share](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_resource_share) | resource |
| [aws_ram_resource_share.private_subnet_share](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_resource_share) | resource |
| [aws_ram_resource_share.public_subnet_share](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_resource_share) | resource |
| [aws_route.private_additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.private_nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.public_additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.public_igw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route_table.nw_fw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.services](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.tgw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.nw_fw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.services](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.tgw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_subnet.nw_fw_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.secondary_private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.secondary_public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.service_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.tgw_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_nat_gateway.nat_gateways](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/nat_gateway) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_flow_log_cloudwatch_iam_role"></a> [create\_flow\_log\_cloudwatch\_iam\_role](#input\_create\_flow\_log\_cloudwatch\_iam\_role) | Determines whether cw flow logs role is created or injected | `bool` | `true` | no |
| <a name="input_create_flow_log_cloudwatch_log_group"></a> [create\_flow\_log\_cloudwatch\_log\_group](#input\_create\_flow\_log\_cloudwatch\_log\_group) | Determines whether VPC flow logs group is created or injected | `bool` | `true` | no |
| <a name="input_create_igw"></a> [create\_igw](#input\_create\_igw) | Determines whether to create an IGW | `bool` | `true` | no |
| <a name="input_create_intra_subnets"></a> [create\_intra\_subnets](#input\_create\_intra\_subnets) | Determines whether intra subnets are created - these are commonly used for EKS Control Plane | `bool` | `false` | no |
| <a name="input_create_nw_firewall_subnets"></a> [create\_nw\_firewall\_subnets](#input\_create\_nw\_firewall\_subnets) | Determines whether subnets for AWS Network Firewall are created | `bool` | `false` | no |
| <a name="input_create_public_subnets"></a> [create\_public\_subnets](#input\_create\_public\_subnets) | Determines whether subnets for public internet facing services is created | `bool` | `true` | no |
| <a name="input_create_services_subnets"></a> [create\_services\_subnets](#input\_create\_services\_subnets) | Determines whether subnets for hosting VPC endpoint services and AWS managed services are created | `bool` | `true` | no |
| <a name="input_create_tgw_subnets"></a> [create\_tgw\_subnets](#input\_create\_tgw\_subnets) | Determines whether subnets for Transit Gateway Attachments are created | `bool` | `false` | no |
| <a name="input_enable_flow_log"></a> [enable\_flow\_log](#input\_enable\_flow\_log) | Determines whether VPC flow logs are enabled | `bool` | `true` | no |
| <a name="input_enable_nat_gateway"></a> [enable\_nat\_gateway](#input\_enable\_nat\_gateway) | Determines whether to enable IPv4 NAT | `bool` | `true` | no |
| <a name="input_endpoint_services"></a> [endpoint\_services](#input\_endpoint\_services) | String list of VPC endpoints to add to the VPC in short form e.g. 'ecr.api' | `list(string)` | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | Name to be used on all the resources as identifier | `string` | n/a | yes |
| <a name="input_private_dedicated_network_acl"></a> [private\_dedicated\_network\_acl](#input\_private\_dedicated\_network\_acl) | Whether to enable dedicated network ACLs on private core subnets | `bool` | `true` | no |
| <a name="input_private_inbound_acl_rules"></a> [private\_inbound\_acl\_rules](#input\_private\_inbound\_acl\_rules) | Private subnets outbound network ACLs | `list(any)` | `[]` | no |
| <a name="input_private_outbound_acl_rules"></a> [private\_outbound\_acl\_rules](#input\_private\_outbound\_acl\_rules) | Private subnets outbound network ACLs | `list(any)` | `[]` | no |
| <a name="input_private_subnet_tags"></a> [private\_subnet\_tags](#input\_private\_subnet\_tags) | Tags to apply to private subnets | `map(string)` | `{}` | no |
| <a name="input_public_dedicated_network_acl"></a> [public\_dedicated\_network\_acl](#input\_public\_dedicated\_network\_acl) | Whether to enable dedicated network ACLs on public core subnets | `bool` | `false` | no |
| <a name="input_public_inbound_acl_rules"></a> [public\_inbound\_acl\_rules](#input\_public\_inbound\_acl\_rules) | Public subnets inbound network ACLs | `list(any)` | <pre>[<br>  {<br>    "cidr_block": "0.0.0.0/0",<br>    "from_port": 0,<br>    "protocol": "tcp",<br>    "rule_action": "allow",<br>    "rule_number": 100,<br>    "to_port": 65535<br>  },<br>  {<br>    "cidr_block": "0.0.0.0/0",<br>    "from_port": 0,<br>    "protocol": "udp",<br>    "rule_action": "allow",<br>    "rule_number": 110,<br>    "to_port": 65535<br>  }<br>]</pre> | no |
| <a name="input_public_outbound_acl_rules"></a> [public\_outbound\_acl\_rules](#input\_public\_outbound\_acl\_rules) | Public subnets outbound network ACLs | `list(any)` | <pre>[<br>  {<br>    "cidr_block": "0.0.0.0/0",<br>    "from_port": 0,<br>    "protocol": "tcp",<br>    "rule_action": "allow",<br>    "rule_number": 100,<br>    "to_port": 65535<br>  },<br>  {<br>    "cidr_block": "0.0.0.0/0",<br>    "from_port": 0,<br>    "protocol": "udp",<br>    "rule_action": "allow",<br>    "rule_number": 110,<br>    "to_port": 65535<br>  }<br>]</pre> | no |
| <a name="input_public_subnet_tags"></a> [public\_subnet\_tags](#input\_public\_subnet\_tags) | Tags to apply to public subnets | `map(string)` | `{}` | no |
| <a name="input_secondary_subnets"></a> [secondary\_subnets](#input\_secondary\_subnets) | Map of secondary subnet configurations by environment | <pre>map(object({<br>    cidr_range          = string<br>    create_public       = bool<br>    create_private      = bool<br>    public_subnet_tags  = optional(map(string), {})<br>    private_subnet_tags = optional(map(string), {})<br>    public_nacl_rules = optional(list(object({<br>      rule_number = number<br>      egress      = bool<br>      protocol    = string<br>      rule_action = string<br>      cidr_block  = string<br>      from_port   = number<br>      to_port     = number<br>    })), [])<br>    private_nacl_rules = optional(list(object({<br>      rule_number = number<br>      egress      = bool<br>      protocol    = string<br>      rule_action = string<br>      cidr_block  = string<br>      from_port   = number<br>      to_port     = number<br>    })), [])<br>    create_custom_route_tables = optional(bool, false)<br>    create_igw_route           = optional(bool, true)<br>    create_nat_routes          = optional(bool, false)<br>    public_routes = optional(list(object({<br>      cidr_block      = string<br>      gateway_id      = optional(string)<br>      nat_gateway_id  = optional(string)<br>      vpc_endpoint_id = optional(string)<br>    })), [])<br>    private_routes = optional(list(object({<br>      cidr_block      = string<br>      gateway_id      = optional(string)<br>      nat_gateway_id  = optional(string)<br>      vpc_endpoint_id = optional(string)<br>    })), [])<br>    shared_public_subnet_principals  = optional(list(string), [])<br>    shared_private_subnet_principals = optional(list(string), [])<br>  }))</pre> | `{}` | no |
| <a name="input_services_inbound_acl_rules"></a> [services\_inbound\_acl\_rules](#input\_services\_inbound\_acl\_rules) | Services subnets inbound network ACLs | `list(any)` | `[]` | no |
| <a name="input_services_outbound_acl_rules"></a> [services\_outbound\_acl\_rules](#input\_services\_outbound\_acl\_rules) | Services subnets inbound network ACLs | `list(any)` | `[]` | no |
| <a name="input_share_private_subnets_principals"></a> [share\_private\_subnets\_principals](#input\_share\_private\_subnets\_principals) | Any principals with which the core private subnets are to be shared | `list(string)` | `[]` | no |
| <a name="input_share_public_subnets_principals"></a> [share\_public\_subnets\_principals](#input\_share\_public\_subnets\_principals) | Any principals with which the core public subnets are to be shared | `list(string)` | `[]` | no |
| <a name="input_single_nat_gateway"></a> [single\_nat\_gateway](#input\_single\_nat\_gateway) | Determines whether to provision IPv4 NAT in each AZ for HA | `bool` | `true` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | The IPv4 CIDR block for the VPC. This forms the core network | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cidr_block"></a> [cidr\_block](#output\_cidr\_block) | The primary CIDR of the VPC |
| <a name="output_intra_subnets"></a> [intra\_subnets](#output\_intra\_subnets) | List of Ids for intra subnets |
| <a name="output_network_acls_by_env"></a> [network\_acls\_by\_env](#output\_network\_acls\_by\_env) | Network ACLs by environment |
| <a name="output_private_subnets"></a> [private\_subnets](#output\_private\_subnets) | List of Ids for private subnets |
| <a name="output_public_subnets"></a> [public\_subnets](#output\_public\_subnets) | List of Ids for private subnets |
| <a name="output_secondary_private_subnets"></a> [secondary\_private\_subnets](#output\_secondary\_private\_subnets) | Map of secondary private subnet IDs |
| <a name="output_secondary_public_subnets"></a> [secondary\_public\_subnets](#output\_secondary\_public\_subnets) | Map of secondary public subnet IDs |
| <a name="output_secondary_route_tables_by_env"></a> [secondary\_route\_tables\_by\_env](#output\_secondary\_route\_tables\_by\_env) | Map of secondary route table IDs by environment |
| <a name="output_secondary_subnet_configurations"></a> [secondary\_subnet\_configurations](#output\_secondary\_subnet\_configurations) | Echo of the Secondary Range Specs by environment |
| <a name="output_secondary_subnets_by_env"></a> [secondary\_subnets\_by\_env](#output\_secondary\_subnets\_by\_env) | Map of subnet IDs grouped by environment |
| <a name="output_services_subnets"></a> [services\_subnets](#output\_services\_subnets) | List of IDs of private subnets |
| <a name="output_vpc_cidrs"></a> [vpc\_cidrs](#output\_vpc\_cidrs) | List of all CIDR ranges associated with the VPC |
| <a name="output_vpc_endpoints"></a> [vpc\_endpoints](#output\_vpc\_endpoints) | Array containing the full resource object and attributes for all endpoints created |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The ID of the VPC |
<!-- END_TF_DOCS -->