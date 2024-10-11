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

resource "aws_lb_target_group" "this_http" {
  name     = "alb-tg-http-${local.friendlyname}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.this.id

  tags = {
    iacpath = "benj-apache-wkwk/alb.tf"
  }
}

resource "aws_lb_listener" "this_http" {
  load_balancer_arn = aws_lb.this.arn
  port              = "80"
  protocol          = "HTTP"
  # ssl_policy        = "ELBSecurityPolicy-2016-08"
  # certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this_http.arn
  }

  tags = {
    iacpath = "benj-apache-wkwk/alb.tf"
  }
}

resource "aws_lb_target_group" "this_https" {
  name     = "alb-tg-https-${local.friendlyname}"
  port     = 443
  protocol = "HTTPS"
  vpc_id   = aws_vpc.this.id

  tags = {
    iacpath = "benj-apache-wkwk/alb.tf"
  }
}

resource "aws_lb_listener" "this_https" {
  depends_on = [module.cert_ap_southeast_1.acm_this, time_sleep.delay_cert_ap_southeast_1]

  load_balancer_arn = aws_lb.this.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"

  #  certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

  #  certificate_arn   = module.cert_ap_southeast_1.acm_this.arn
  certificate_arn = module.cert_ap_southeast_1.acm_this.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this_https.arn
  }

  tags = {
    iacpath = "benj-apache-wkwk/alb.tf"
  }
}

resource "aws_lb_target_group_attachment" "this_http" {
  target_group_arn = aws_lb_target_group.this_http.arn
  target_id        = aws_instance.this.id
  # depends_on       = [aws_lb_target_group.this]
}

resource "aws_lb_target_group_attachment" "this_https" {
  target_group_arn = aws_lb_target_group.this_https.arn
  target_id        = aws_instance.this.id
  # depends_on       = [aws_lb_target_group.this]
}
