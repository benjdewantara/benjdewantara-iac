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

  vpc_security_group_ids      = [module.sg_this.security_group_id]
  create_security_group       = false
  associate_public_ip_address = true
  instance_type               = "t3.medium"
  subnet_id                   = local.create_vpc ? module.vpc.public_subnets[0] : ""
  user_data_base64            = base64encode(data.template_file.user_data.rendered)
  iam_instance_profile        = module.iam_role.instance_profile_name

  tags = {
    iacpath = "bnj-directus-tutor/ec2.tf"
  }
}
