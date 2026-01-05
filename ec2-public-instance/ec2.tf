locals {
  ec2_instance_name = "${local.projectname}-${random_string.this.result}"
  time_now          = timestamp()
}

# this recreates resource random_string each time `terraform apply` occcurs
resource "random_string" "this" {
  keepers = { marker = local.time_now }

  length    = 4
  lower     = true
  min_lower = 4
  special   = false
}

data "template_file" "user_data" {
  template = file("${path.module}/user_data.sh")

  vars = {
    # user_data_cwagent_config_json = file("${path.module}/user_data_cwagent_config.json")
    user_data_cwagent_config_json = ""
  }
}

# inspired by the example on https://registry.terraform.io/modules/terraform-aws-modules/ec2-instance/aws/latest
# also see https://github.com/terraform-aws-modules/terraform-aws-ec2-instance/blob/master/examples/complete/main.tf
module "ec2_this" {
  depends_on = [random_string.this]

  source = "git::https://github.com/terraform-aws-modules/terraform-aws-ec2-instance.git"
  count  = local.create_vpc ? 1 : 0

  name = local.ec2_instance_name

  create_security_group          = true
  security_group_name            = local.ec2_instance_name
  security_group_use_name_prefix = false

  security_group_ingress_rules = {
    1 = {
      cidr_ipv4 = "0.0.0.0/0",
      # cidr_ipv6   = "::/0"
      description = "Allow incoming all",
      # from_port   = 0,
      ip_protocol = "-1",
      # to_port     = 0,

      tags = {
        iacpath = "ec2-public-instance/ec2.tf"
      },
    }
  }

  associate_public_ip_address = true

  instance_type = "t3.micro"

  subnet_id = local.create_vpc ? module.vpc.public_subnets[0] : ""

  user_data_base64 = base64encode(data.template_file.user_data.rendered)

  iam_instance_profile = module.iam_role.instance_profile_name

  tags = {
    iacpath = "ec2-public-instance/ec2.tf"
  }
}
