#--------------------------------------------------------------
# Endpoints
#--------------------------------------------------------------

module "vpc_endpoints" {
  # https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws//modules/vpc-endpoints
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "~> 6.0"

  vpc_id = module.vpc.vpc_id

  create_security_group      = true
  security_group_name_prefix = "${var.name}-vpc-endpoints-"
  security_group_description = "VPC endpoint security group"
  security_group_rules = {
    ingress_https = {
      description = "HTTPS from VPC"
      cidr_blocks = [module.vpc.vpc_cidr_block]
    }
  }

  endpoints = local.vpc_endpoints
}