# -------------------------
# ALB Security Group
# -------------------------
resource "aws_security_group" "alb_sg" {
  name        = "jenkins-alb-sg"
  description = "Allow HTTP/HTTPS to ALB"
  vpc_id      = aws_vpc.jenkins_vpc.id

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "jenkins-alb-sg" }
}

# -------------------------
# Jenkins Master SG
# -------------------------
resource "aws_security_group" "jenkins_master_sg" {
  name        = "jenkins-master-sg"
  description = "Jenkins Master SG"
  vpc_id      = aws_vpc.jenkins_vpc.id

  # REMOVE the old inline "HTTP from ALB" block that used security_groups = [...]
  # We'll add a proper rule below.

  ingress {
    description = "SSH from your IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["86.41.40.161/32"] # your IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "jenkins-master-sg" }
}

# Allow ALB -> Jenkins:8080 (correct way)
# resource "aws_security_group_rule" "jenkins_from_alb" {
#   type                     = "ingress"
#   description              = "Allow ALB to reach Jenkins on 8080"
#   from_port                = 8080
#   to_port                  = 8080
#   protocol                 = "tcp"
#   security_group_id        = aws_security_group.jenkins_master_sg.id
#   source_security_group_id = aws_security_group.alb_sg.id
# }

# Allow ALB -> Instance :80
resource "aws_security_group_rule" "web_from_alb" {
  type                     = "ingress"
  description              = "Allow ALB to reach instance on 80"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.jenkins_master_sg.id
  source_security_group_id = aws_security_group.alb_sg.id
}


# -------------------------
# EFS SG
# -------------------------
resource "aws_security_group" "efs_sg" {
  name        = "jenkins-efs-sg"
  description = "Allow NFS from Jenkins"
  vpc_id      = aws_vpc.jenkins_vpc.id

  # REMOVE the old inline NFS ingress with security_groups = [...]
  # We'll add a proper rule below.

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "jenkins-efs-sg" }
}

# Allow Jenkins -> EFS:2049 (NFS)
resource "aws_security_group_rule" "efs_from_jenkins" {
  type                     = "ingress"
  description              = "Allow NFS from Jenkins Master"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  security_group_id        = aws_security_group.efs_sg.id
  source_security_group_id = aws_security_group.jenkins_master_sg.id
}
