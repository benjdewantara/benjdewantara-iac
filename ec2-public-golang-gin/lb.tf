resource "aws_lb" "this" {
  name               = local.projectname
  subnets            = module.vpc.public_subnets
  security_groups    = [aws_security_group.this.id]
  load_balancer_type = "application"

  tags = {
    iacpath = "ec2-public-golang-gin/lb.tf"
  }
}

locals {
  ports_target = tolist(["8081", "8082"])
}

resource "aws_lb_target_group" "this" {
  name     = local.projectname
  port     = 123 # will be overridden anyway when registering a target
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id

  health_check {
    matcher = "200,404"
  }
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80

  default_action {
    type = "forward"

    forward {
      target_group {
        arn = aws_lb_target_group.this.arn
      }
    }
  }

  tags = {
    iacpath = "ec2-public-golang-gin/lb.tf"
  }
}

resource "aws_lb_target_group_attachment" "this" {
  for_each = toset(local.ports_target)
  # for_each = aws_lb_target_group.this

  target_group_arn = aws_lb_target_group.this.arn
  target_id        = module.ec2_this[0].id
  port             = each.value
}
