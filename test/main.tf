data "aws_caller_identity" "current" {}

# Do testing out of the standard region
provider "aws" {
  region                             = "eu-west-2"
  retry_mode                         = "adaptive"
  max_retries                        = 10
  token_bucket_rate_limiter_capacity = 5000
}

module "example" {
  source = "./.."

  name     = "testing_vpc"
  vpc_cidr = "10.240.0.0/16"

  single_nat_gateway = false

  share_private_subnets_principals = []
  share_public_subnets_principals  = []

  secondary_subnets = {
    "dev" = {
      cidr_range        = "10.241.0.0/16"
      create_public     = true
      create_private    = true
      create_igw_route  = true
      create_nat_routes = true
      public_subnet_tags = {
        "kubernetes.io/role/elb" = "1"
      }
      private_subnet_tags = {
        "kubernetes.io/role/internal-elb" = "1"
      }
      private_nacl_rules = [
        {
          rule_number = 100
          egress      = false
          protocol    = "tcp"
          rule_action = "allow"
          cidr_block  = "10.241.0.0/16"
          from_port   = 0
          to_port     = 65535
        },
        {
          rule_number = 110
          egress      = false
          protocol    = "tcp"
          rule_action = "allow"
          cidr_block  = "10.240.0.0/16"
          from_port   = 0
          to_port     = 65535
        },
        {
          rule_number = 120
          egress      = false
          protocol    = "tcp"
          rule_action = "deny"
          cidr_block  = "10.242.0.0/16"
          from_port   = 0
          to_port     = 65535
        },
        {
          rule_number = 130
          egress      = false
          protocol    = "tcp"
          rule_action = "deny"
          cidr_block  = "10.243.0.0/16"
          from_port   = 0
          to_port     = 65535
        },
        {
          rule_number = 100
          egress      = true
          protocol    = "tcp"
          rule_action = "allow"
          cidr_block  = "10.241.0.0/16"
          from_port   = 0
          to_port     = 65535
        },
        {
          rule_number = 110
          egress      = true
          protocol    = "tcp"
          rule_action = "allow"
          cidr_block  = "10.240.0.0/16"
          from_port   = 0
          to_port     = 65535
        },
        {
          rule_number = 120
          egress      = true
          protocol    = "tcp"
          rule_action = "deny"
          cidr_block  = "10.242.0.0/16"
          from_port   = 0
          to_port     = 65535
        },
        {
          rule_number = 130
          egress      = true
          protocol    = "tcp"
          rule_action = "deny"
          cidr_block  = "10.243.0.0/16"
          from_port   = 0
          to_port     = 65535
        },
        {
          rule_number = 140
          egress      = true
          protocol    = "tcp"
          rule_action = "allow"
          cidr_block  = "0.0.0.0/0"
          from_port   = 443
          to_port     = 443
        }
      ]
      public_nacl_rules = [
        {
          rule_number = 100
          egress      = false
          protocol    = "tcp"
          rule_action = "allow"
          cidr_block  = "0.0.0.0/0"
          from_port   = 443
          to_port     = 443
        },
        {
          rule_number = 110
          egress      = false
          protocol    = "tcp"
          rule_action = "allow"
          cidr_block  = "0.0.0.0/0"
          from_port   = 1024
          to_port     = 65535
        },
        {
          rule_number = 100
          egress      = true
          protocol    = "tcp"
          rule_action = "allow"
          cidr_block  = "0.0.0.0/0"
          from_port   = 443
          to_port     = 443
        },
        {
          rule_number = 110
          egress      = true
          protocol    = "tcp"
          rule_action = "allow"
          cidr_block  = "0.0.0.0/0"
          from_port   = 1024
          to_port     = 65535
        }
      ]
      shared_public_subnet_principals  = []
      shared_private_subnet_principals = []
    }
    "prod" = {
      cidr_range        = "10.242.0.0/16"
      create_public     = true
      create_private    = true
      create_igw_route  = true
      create_nat_routes = true
      public_subnet_tags = {
        "kubernetes.io/role/elb" = "1"
      }
      private_subnet_tags = {
        "kubernetes.io/role/internal-elb" = "1"
      }
      private_nacl_rules = [
        {
          rule_number = 100
          egress      = false
          protocol    = "tcp"
          rule_action = "allow"
          cidr_block  = "10.242.0.0/16"
          from_port   = 0
          to_port     = 65535
        },
        {
          rule_number = 110
          egress      = false
          protocol    = "tcp"
          rule_action = "allow"
          cidr_block  = "10.240.0.0/16"
          from_port   = 0
          to_port     = 65535
        },
        {
          rule_number = 120
          egress      = false
          protocol    = "tcp"
          rule_action = "deny"
          cidr_block  = "10.241.0.0/16"
          from_port   = 0
          to_port     = 65535
        },
        {
          rule_number = 130
          egress      = false
          protocol    = "tcp"
          rule_action = "deny"
          cidr_block  = "10.243.0.0/16"
          from_port   = 0
          to_port     = 65535
        },
        {
          rule_number = 100
          egress      = true
          protocol    = "tcp"
          rule_action = "allow"
          cidr_block  = "10.242.0.0/16"
          from_port   = 0
          to_port     = 65535
        },
        {
          rule_number = 110
          egress      = true
          protocol    = "tcp"
          rule_action = "allow"
          cidr_block  = "10.240.0.0/16"
          from_port   = 0
          to_port     = 65535
        },
        {
          rule_number = 120
          egress      = true
          protocol    = "tcp"
          rule_action = "deny"
          cidr_block  = "10.241.0.0/16"
          from_port   = 0
          to_port     = 65535
        },
        {
          rule_number = 130
          egress      = true
          protocol    = "tcp"
          rule_action = "deny"
          cidr_block  = "10.243.0.0/16"
          from_port   = 0
          to_port     = 65535
        },
        {
          rule_number = 140
          egress      = true
          protocol    = "tcp"
          rule_action = "allow"
          cidr_block  = "0.0.0.0/0"
          from_port   = 443
          to_port     = 443
        }
      ]
      public_nacl_rules = [
        {
          rule_number = 100
          egress      = false
          protocol    = "tcp"
          rule_action = "allow"
          cidr_block  = "0.0.0.0/0"
          from_port   = 443
          to_port     = 443
        },
        {
          rule_number = 110
          egress      = false
          protocol    = "tcp"
          rule_action = "allow"
          cidr_block  = "0.0.0.0/0"
          from_port   = 1024
          to_port     = 65535
        },
        {
          rule_number = 100
          egress      = true
          protocol    = "tcp"
          rule_action = "allow"
          cidr_block  = "0.0.0.0/0"
          from_port   = 443
          to_port     = 443
        },
        {
          rule_number = 110
          egress      = true
          protocol    = "tcp"
          rule_action = "allow"
          cidr_block  = "0.0.0.0/0"
          from_port   = 1024
          to_port     = 65535
        }
      ]
    },
    "demo" = {
      cidr_range        = "10.243.0.0/16"
      create_public     = true
      create_private    = true
      create_igw_route  = true
      create_nat_routes = true
      public_subnet_tags = {
        "kubernetes.io/role/elb" = "1"
      }
      private_subnet_tags = {
        "kubernetes.io/role/internal-elb" = "1"
      }
      private_nacl_rules = [
        {
          rule_number = 100
          egress      = false
          protocol    = "tcp"
          rule_action = "allow"
          cidr_block  = "10.243.0.0/16"
          from_port   = 0
          to_port     = 65535
        },
        {
          rule_number = 110
          egress      = false
          protocol    = "tcp"
          rule_action = "allow"
          cidr_block  = "10.240.0.0/16"
          from_port   = 0
          to_port     = 65535
        },
        {
          rule_number = 120
          egress      = false
          protocol    = "tcp"
          rule_action = "deny"
          cidr_block  = "10.241.0.0/16"
          from_port   = 0
          to_port     = 65535
        },
        {
          rule_number = 130
          egress      = false
          protocol    = "tcp"
          rule_action = "deny"
          cidr_block  = "10.242.0.0/16"
          from_port   = 0
          to_port     = 65535
        },
        {
          rule_number = 100
          egress      = true
          protocol    = "tcp"
          rule_action = "allow"
          cidr_block  = "10.243.0.0/16"
          from_port   = 0
          to_port     = 65535
        },
        {
          rule_number = 110
          egress      = true
          protocol    = "tcp"
          rule_action = "allow"
          cidr_block  = "10.240.0.0/16"
          from_port   = 0
          to_port     = 65535
        },
        {
          rule_number = 120
          egress      = true
          protocol    = "tcp"
          rule_action = "deny"
          cidr_block  = "10.241.0.0/16"
          from_port   = 0
          to_port     = 65535
        },
        {
          rule_number = 130
          egress      = true
          protocol    = "tcp"
          rule_action = "deny"
          cidr_block  = "10.242.0.0/16"
          from_port   = 0
          to_port     = 65535
        },
        {
          rule_number = 140
          egress      = true
          protocol    = "tcp"
          rule_action = "allow"
          cidr_block  = "0.0.0.0/0"
          from_port   = 443
          to_port     = 443
        }
      ]
      public_nacl_rules = [
        {
          rule_number = 100
          egress      = false
          protocol    = "tcp"
          rule_action = "allow"
          cidr_block  = "0.0.0.0/0"
          from_port   = 443
          to_port     = 443
        },
        {
          rule_number = 110
          egress      = false
          protocol    = "tcp"
          rule_action = "allow"
          cidr_block  = "0.0.0.0/0"
          from_port   = 1024
          to_port     = 65535
        },
        {
          rule_number = 100
          egress      = true
          protocol    = "tcp"
          rule_action = "allow"
          cidr_block  = "0.0.0.0/0"
          from_port   = 443
          to_port     = 443
        },
        {
          rule_number = 110
          egress      = true
          protocol    = "tcp"
          rule_action = "allow"
          cidr_block  = "0.0.0.0/0"
          from_port   = 1024
          to_port     = 65535
        }
      ]
    }
  }
}
