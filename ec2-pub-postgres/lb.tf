resource "aws_lb" "this" {
  name               = local.projectname
  subnets            = module.vpc.public_subnets
  security_groups    = [aws_security_group.this.id]
  load_balancer_type = "application"

  tags = {
    iacpath = "ec2-pub-postgres/lb.tf"
  }
}

resource "aws_lb_target_group" "this" {
  for_each = local.microservice_specs

  name     = "${local.projectname}-${each.key}"
  port     = each.value["port"] # will be overridden anyway when registering a target
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id

  health_check {
    matcher = "200,404"
  }
}

resource "aws_lb_target_group_attachment" "this" {
  for_each = aws_lb_target_group.this

  target_group_arn = each.value.arn
  target_id        = module.ec2_this[0].id
  port             = each.value.port
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Benj says you should use HTTPS"
      status_code  = "200"
    }
  }

  tags = {
    iacpath = "ec2-pub-postgres/lb.tf"
  }
}

resource "aws_lb_listener" "this_https" {
  load_balancer_arn = aws_lb.this.arn
  port              = 443
  certificate_arn   = module.cert_ap_southeast_1.certificate_arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "N/A"
      status_code  = "503"
    }
  }

  tags = {
    iacpath = "ec2-pub-postgres/lb.tf"
  }
}

resource "aws_lb_listener_rule" "this" {
  for_each = aws_lb_target_group.this

  listener_arn = aws_lb_listener.this_https.arn

  action {
    type             = "forward"
    target_group_arn = each.value.arn
  }

  condition {
    path_pattern {
      values = ["/api/${each.key}/*"]
    }
  }
}
