# ------------------------
# ALB
# ------------------------
resource "aws_lb" "alb" {
  name               = "${var.project}-${var.environment}-app-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.alb_sg.id
  ]

  subnets = [
    aws_subnet.public_subnet_1a.id,
    aws_subnet.public_subnet_1c.id
  ]

  tags = {
    Name    = "${var.project}-${var.environment}-app-alb"
    Project = var.project
    Env     = var.environment
  }
}

# リスナーポート80
resource "aws_lb_listener" "alb_listener_http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
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



# リスナーポート443
resource "aws_lb_listener" "alb_listener_https" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate_validation.alb_cert.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target_group.arn
  }
}



# ------------------------
# Target Group
# ------------------------
resource "aws_lb_target_group" "alb_target_group" {
  name     = "${var.project}-${var.environment}-app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name    = "${var.project}-${var.environment}-app-tg"
    Project = var.project
    Env     = var.environment
  }
}


# ------------------------
# Auto scaling group
# ------------------------
resource "aws_autoscaling_group" "app_asg" {
  name             = "${var.project}-${var.environment}-app-asg"
  min_size         = 2
  max_size         = 4
  desired_capacity = 2
  vpc_zone_identifier = [
    aws_subnet.app_private_subnet_1a.id,
    aws_subnet.app_private_subnet_1c.id
  ]

  target_group_arns = [
    aws_lb_target_group.alb_target_group.arn
  ]

  health_check_type         = "ELB"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project}-${var.environment}-app-server"
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = var.project
    propagate_at_launch = true
  }

  tag {
    key                 = "Env"
    value               = var.environment
    propagate_at_launch = true
  }

  tag {
    key                 = "Type"
    value               = "app"
    propagate_at_launch = true
  }
}


# ------------------------
# Target Tracking Scaling Policy
# ------------------------
resource "aws_autoscaling_policy" "app_asg_cpu_policy" {
  name                   = "${var.project}-${var.environment}-app-asg-cpu-policy"
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 50.0
  }
}