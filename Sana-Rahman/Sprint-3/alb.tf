# Create an Application Load Balancer (ALB)
resource "aws_lb" "my_alb" {
  name                             = var.alb_name
  internal                         = var.alb_internal
  load_balancer_type               = var.load_balancer_type
  enable_deletion_protection       = var.enable_deletion_protection
  security_groups                  = [aws_security_group.alb_sg.id]
  subnets                          = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]
  enable_http2                     = true
  enable_cross_zone_load_balancing = true
}

# Create a Route53 record for subdomain
resource "aws_route53_record" "subdomain" {
  zone_id         = data.aws_route53_zone.hosted_zone.zone_id
  name            = var.subdomain_name
  type            = "CNAME"
  ttl             = 300
  records         = [aws_lb.my_alb.dns_name]
  allow_overwrite = true
}

# Obtain ACM certificate for the subdomain
resource "aws_acm_certificate" "my_certificate" {
  domain_name       = aws_route53_record.subdomain.name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# Create Route53 record for ACM certificate validation
resource "aws_route53_record" "my_validation" {
  zone_id = data.aws_route53_zone.hosted_zone.zone_id
  name    = tolist(aws_acm_certificate.my_certificate.domain_validation_options)[0].resource_record_name
  type    = tolist(aws_acm_certificate.my_certificate.domain_validation_options)[0].resource_record_type
  records = [tolist(aws_acm_certificate.my_certificate.domain_validation_options)[0].resource_record_value]
  ttl     = 300
}

# Validate ACM certificate
resource "aws_acm_certificate_validation" "my_certificate_validation" {
  certificate_arn         = aws_acm_certificate.my_certificate.arn
  validation_record_fqdns = [aws_route53_record.my_validation.fqdn]
}

# Create an HTTP listener for redirect
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.my_alb.arn
  port              = var.http_port
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# Create an HTTPS listener for frontend
resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.my_alb.arn
  port              = var.https_port
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.my_certificate.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_tg.arn
  }
}

# Create listeners for frontend and backend
resource "aws_lb_listener" "frontend_listener" {
  load_balancer_arn = aws_lb.my_alb.arn
  port              = var.custom_port_1
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_tg.arn
  }
}

# Load balancer listener for the backend
resource "aws_lb_listener" "backend_listener" {
  load_balancer_arn = aws_lb.my_alb.arn
  port              = var.custom_port_2
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.my_certificate.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_tg.arn
  }
}

# Create frontend and backend target groups
resource "aws_lb_target_group" "frontend_tg" {
  name        = var.front_tg_name
  target_type = "ip"
  port        = var.custom_port_1
  protocol    = "HTTP"
  vpc_id      = aws_vpc.custom_vpc.id

  # Health check settings
  health_check {
    enabled             = true
    interval            = 300
    path                = "/"
    timeout             = 60
    matcher             = 200
    healthy_threshold   = 5
    unhealthy_threshold = 5
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Target group for the backend
resource "aws_lb_target_group" "backend_tg" {
  name        = var.backend_tg_name
  port        = var.custom_port_2
  protocol    = "HTTP"
  vpc_id      = aws_vpc.custom_vpc.id
  target_type = "ip"

  # Health check settings
  health_check {
    enabled             = true
    interval            = 300
    path                = "/"
    timeout             = 60
    matcher             = 200
    healthy_threshold   = 5
    unhealthy_threshold = 5
  }

  lifecycle {
    create_before_destroy = true
  }
}
