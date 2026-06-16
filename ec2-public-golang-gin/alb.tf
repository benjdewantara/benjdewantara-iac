resource "aws_alb" "this" {
  name               = local.projectname
  subnets            = module.vpc.public_subnets
  load_balancer_type = "application"

  tags = {
    iacpath = "ec2-public-golang-gin/alb.tf"
  }
}
