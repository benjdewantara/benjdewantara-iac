module "web_server_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = local.projectname
  description = "Security group sample"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = -1
      description = "Allow all incoming IPv4"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  ingress_with_ipv6_cidr_blocks = [
    {
      from_port        = 0
      to_port          = 0
      protocol         = -1
      description      = "Allow all incoming IPv6"
      ipv6_cidr_blocks = "::/0"
    },
  ]
}
