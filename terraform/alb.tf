# Create ALB
resource "aws_lb" "jenkins_alb" {
  name               = "jenkins-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [
    aws_subnet.public_subnet_1.id,
    aws_subnet.public_subnet_2.id
  ]

  tags = {
    Name = "jenkins-alb"
  }
}

# Target group for Jenkins EC2 instances
# resource "aws_lb_target_group" "jenkins_tg" {
#   name        = "jenkins-target-group"
#   port        = 8080
#   protocol    = "HTTP"
#   target_type = "instance"
#   vpc_id      = aws_vpc.jenkins_vpc.id

#   health_check {
#     path                = "/login"
#     protocol            = "HTTP"
#     interval            = 30
#     timeout             = 5
#     healthy_threshold   = 2
#     unhealthy_threshold = 2
#     matcher             = "200-399"
#   }

#   tags = {
#     Name = "jenkins-tg"
#   }
# }

resource "aws_lb_target_group" "web_tg" {
  name        = "web-target-group"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.jenkins_vpc.id

  health_check {
    path                = "/health.txt"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
    matcher             = "200-399"
  }

  tags = { Name = "web-tg" }
}


# HTTP Listener on port 80
resource "aws_lb_listener" "jenkins_listener" {
  load_balancer_arn = aws_lb.jenkins_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}
