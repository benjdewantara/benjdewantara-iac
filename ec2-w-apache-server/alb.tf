resource "aws_lb" "this" {
  name               = "alb-${local.friendlyname}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.this.id]

  # subnets = [for subnet in aws_subnet.public : subnet.id]
  subnets = [aws_subnet.aza_web.id, aws_subnet.azb_web.id]

  tags = {
    iacpath = "benj-apache-wkwk/alb.tf"
  }
}

resource "aws_lb_target_group" "this" {
  name     = "alb-tg-${local.friendlyname}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.this.id

  tags = {
    iacpath = "benj-apache-wkwk/alb.tf"
  }
}

resource "aws_lb_target_group_attachment" "test" {
  target_group_arn = aws_lb_target_group.this.arn
  target_id        = aws_instance.this.id
  # depends_on       = [aws_lb_target_group.this]
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = "80"
  protocol          = "HTTP"
  # ssl_policy        = "ELBSecurityPolicy-2016-08"
  # certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }

  tags = {
    iacpath = "benj-apache-wkwk/alb.tf"
  }
}
