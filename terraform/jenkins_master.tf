# Jenkins EC2 Instance
data "aws_ami" "ubuntu_jammy" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "jenkins_master" {
  ami                    = data.aws_ami.ubuntu_jammy.id
  instance_type          = "t3.medium"
  subnet_id              = aws_subnet.public_subnet_1.id
  vpc_security_group_ids = [aws_security_group.jenkins_master_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.jenkins_ec2_profile.name
  key_name               = var.key_pair_name

  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              set -euo pipefail
              export DEBIAN_FRONTEND=noninteractive

              apt-get update -y
              apt-get install -y nginx
              apt-get install -y nfs-common

              # Simple index + health page
              echo "OK: $(hostname)" > /var/www/html/index.html
              echo "healthy" > /var/www/html/health.txt

              systemctl enable --now nginx
              systemctl restart nginx

              # --- EFS mount (test path) ---
              EFS_DNS="${aws_efs_file_system.jenkins_efs.dns_name}"

              mkdir -p /var/lib/efs

              # ensure fstab entry (idempotent)
              grep -q "${aws_efs_file_system.jenkins_efs.dns_name}:/" /etc/fstab || \
                echo "${aws_efs_file_system.jenkins_efs.dns_name}:/ /var/lib/efs nfs4 nfsvers=4.1,_netdev 0 0" | sudo tee -a /etc/fstab

              # wait for EFS to resolve/listen
              i=0; until nc -z ${aws_efs_file_system.jenkins_efs.dns_name} 2049 || [ $i -gt 60 ]; do i=$((i+1)); sleep 2; done

              mount -a

              # write a marker file to confirm mount works
              echo "efs-mounted-from-$(hostname) @ $(date -Is)" > /mnt/efs/efs_is_working.txt
              EOF

  tags = {
    Name = "jenkins-master"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Attach EC2 to ALB Target Group
# resource "aws_lb_target_group_attachment" "jenkins_attachment" {
#   target_group_arn = aws_lb_target_group.jenkins_tg.arn
#   target_id        = aws_instance.jenkins_master.id
#   port             = 8080
# }

resource "aws_lb_target_group_attachment" "web_attachment" {
  target_group_arn = aws_lb_target_group.web_tg.arn
  target_id        = aws_instance.jenkins_master.id
  port             = 80
}
