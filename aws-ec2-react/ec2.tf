data "local_file" "docker" {
  filename = "${path.module}/../scripts/docker-dockercompose.sh"
}

data "local_file" "node_npm" {
  filename = "${path.module}/../scripts/node_npm.sh"
}

data "local_file" "pnpm" {
  filename = "${path.module}/../scripts/pnpm.sh"
}

locals {
  user_data_accumulated = join("\n",
    [
      data.local_file.docker.content,
      data.local_file.node_npm.content,
      data.local_file.pnpm.content,
    ]
  )
}

# inspired by the example on https://registry.terraform.io/modules/terraform-aws-modules/ec2-instance/aws/latest
# also see https://github.com/terraform-aws-modules/terraform-aws-ec2-instance/blob/master/examples/complete/main.tf
module "ec2_this" {
  # depends_on = [random_string.this, aws_security_group.this]
  depends_on = [aws_security_group.this]

  source = "git::https://github.com/terraform-aws-modules/terraform-aws-ec2-instance.git"
  count  = local.create_vpc ? 1 : 0

  name = local.ec2_instance_name

  vpc_security_group_ids      = [aws_security_group.this.id]
  create_security_group       = false
  associate_public_ip_address = true
  instance_type               = "t3.small"
  subnet_id                   = local.create_vpc ? module.vpc.public_subnets[0] : ""
  user_data_base64            = base64encode(local.user_data_accumulated)
  iam_instance_profile        = module.iam_role.instance_profile_name

  tags = {
    iacpath = "aws-ec2-react/ec2.tf"
  }
}
