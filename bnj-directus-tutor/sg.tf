resource "aws_security_group" "this" {
  vpc_id      = module.vpc.vpc_id
  name        = local.projectname
  description = "Security group for ${local.projectname}"
}

resource "aws_vpc_security_group_egress_rule" "this_ipv4" {
  ip_protocol       = "-1"
  security_group_id = aws_security_group.this.id

  cidr_ipv4 = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "this_ipv6" {
  ip_protocol       = "-1"
  security_group_id = aws_security_group.this.id

  cidr_ipv6 = "::/0"
}

resource "aws_vpc_security_group_ingress_rule" "this_ipv4" {
  ip_protocol       = "-1"
  security_group_id = aws_security_group.this.id

  cidr_ipv4 = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "this_ipv6" {
  ip_protocol       = "-1"
  security_group_id = aws_security_group.this.id

  cidr_ipv6 = "::/0"
}
