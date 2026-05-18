module "vpc" {
  source     = "git::https://github.com/terraform-aws-modules/terraform-aws-vpc.git"
  create_vpc = local.create_vpc

  name = local.projectname
  cidr = local.cidr_vpc

  azs = local.azs
  # intra_subnets  = [for i in range(0, 0 + 3) : local.cidrs_subnet[i]]
  # private_subnets = [for i in range(0, 0 + 3) : local.cidrs_subnet[i]]
  public_subnets  = [for i in range(3, 3 + 3) : local.cidrs_subnet[i]]

  create_igw = true

  manage_default_security_group = false

  tags = {
    iacpath = "ec2-public-instance/vpc.tf"
  }
}
