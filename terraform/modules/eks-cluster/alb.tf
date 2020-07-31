# ALB
resource "aws_lb" "main" {
  name               = "${var.cluster_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.alb-sg.id}"]
  subnets            = ["${aws_subnet.main.*.id}"]
  idle_timeout       = 1800
  enable_http2       = false
  tags = {
    environment = "${var.cluster_name}"
  }
}

# Target group for ALB
resource "aws_lb_target_group" "main" {
  name     = "${var.cluster_name}-alb-tg"
  port     = "${var.alb_target_port}"
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.main.id}"
  tags = {
    environment = "${var.cluster_name}"
  }
  health_check {
    protocol            = "HTTP"
    path                = "/ping"
    timeout             = 5
    interval            = 10
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

# Redirect HTTP -> HTTPS
resource "aws_lb_listener" "main_http" {
  load_balancer_arn = "${aws_lb.main.arn}"
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# HTTPS Listener
resource "aws_lb_listener" "main_https" {
  load_balancer_arn = "${aws_lb.main.arn}"
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = "${var.domain_certificate_id}"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.main.arn}"
  }
}

# Security group for ALB
resource "aws_security_group" "alb-sg" {
  name   = "${var.cluster_name}-ALB"
  vpc_id = "${aws_vpc.main.id}"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name        = "${var.cluster_name}-ALB"
    environment = "${var.cluster_name}"
  }
}

# Security group ports for ALB
resource "aws_security_group_rule" "alb-sg-ports" {
  count                    = "${length(var.alb_secgroup_ports)}"
  type                     = "ingress"
  from_port                = "${var.alb_secgroup_ports[count.index]}"
  to_port                  = "${var.alb_secgroup_ports[count.index]}"
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.alb-sg.id}"
  cidr_blocks              = ["0.0.0.0/0"]
  description              = "ALB Security groups"
}

