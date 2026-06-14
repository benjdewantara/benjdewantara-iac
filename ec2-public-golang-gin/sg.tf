resource "aws_security_group" "this" {
  vpc_id      = module.vpc.vpc_id
  name        = local.projectname
  description = "Security group for ${local.projectname}"

  egress {
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description      = "Allow outgoing packets"
    from_port        = 0
    protocol         = "-1"
    to_port          = 0
  }

  ingress {
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description      = "Allow incoming packets"
    from_port        = 0
    protocol         = "-1"
    to_port          = 0
  }
}


# module "sg_this" {
#   source = "terraform-aws-modules/security-group/aws"
#
#   name            = local.projectname
#   description     = "Security group sample"
#   vpc_id          = module.vpc.vpc_id
#   use_name_prefix = false
#
#   ingress_rules = {
#     a1 = {
#       from_port   = 0
#       to_port     = 0
#       ip_protocol = -1
#       cidr_ipv4   = "0.0.0.0/0"
#       description = "HTTPS from VPC"
#     }
#
#     a2 = {
#       from_port   = 0
#       to_port     = 0
#       protocol    = -1
#       description = "Allow all incoming IPv6"
#       cidr_ipv6   = "::/0"
#     }
#
#     all-from-self = {
#       ip_protocol                  = "-1"
#       referenced_security_group_id = "self"
#       description                  = "All protocols from self"
#     }
#   }
#
#   egress_rules = {
#     all = {
#       ip_protocol = "-1"
#       cidr_ipv4   = "0.0.0.0/0"
#       description = "All outbound"
#     }
#   }
#
#   tags = {
#     iacpath = "bnj-golang-gin-tutor/sg.tf"
#   }
# }


# module "sg_this2" {
#   source = "terraform-aws-modules/security-group/aws"
#
#   name            = local.projectname
#   description     = "Security group sample"
#   vpc_id          = module.vpc.vpc_id
#   use_name_prefix = false
#
#   ingress_with_cidr_blocks = [
#     {
#       from_port   = 0
#       to_port     = 0
#       protocol    = -1
#       description = "Allow all incoming IPv4"
#       cidr_blocks = "0.0.0.0/0"
#     },
#   ]
#
#   ingress_with_ipv6_cidr_blocks = [
#     {
#       from_port        = 0
#       to_port          = 0
#       protocol         = -1
#       description      = "Allow all incoming IPv6"
#       ipv6_cidr_blocks = "::/0"
#     },
#   ]
#
#   egress_with_cidr_blocks = [
#     {
#       from_port   = 0
#       to_port     = 0
#       protocol    = -1
#       description = "Allow all outgoing IPv4"
#       cidr_blocks = "0.0.0.0/0"
#     },
#   ]
#
#   egress_with_ipv6_cidr_blocks = [
#     {
#       from_port        = 0
#       to_port          = 0
#       protocol         = -1
#       description      = "Allow all outgoing IPv6"
#       ipv6_cidr_blocks = "::/0"
#     },
#   ]
#
#   tags = {
#     iacpath = "bnj-golang-gin-tutor/sg.tf"
#   }
# }
