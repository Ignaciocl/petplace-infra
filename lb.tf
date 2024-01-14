resource "aws_lb" "main" {
  name               = "generalLb"
  internal           = false
  load_balancer_type = "application"

  subnets                    = module.vpc.public_subnets
  enable_deletion_protection = false
  security_groups = [aws_security_group.https.id]

}

resource "aws_alb_target_group" "main" {
  name        = "generalLb-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "404"
    timeout             = "3"
    path                = "/"
    unhealthy_threshold = "2"
  }
  depends_on = [
    aws_lb.main
  ]
}

resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_lb.main.id
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = 443
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}


resource "aws_alb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn

  port              = 443
  protocol          = "HTTPS"

  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.api.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.main.arn
  }
}
