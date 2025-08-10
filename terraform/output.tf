output "vpc_id" {
  value = aws_vpc.jenkins_vpc.id
}

output "public_subnet_ids" {
  value = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
}

output "jenkins_master_sg_id" {
  value = aws_security_group.jenkins_master_sg.id
}

output "alb_sg_id" {
  value = aws_security_group.alb_sg.id
}

output "efs_id" {
  value = aws_efs_file_system.jenkins_efs.id
}
output "alb_dns_name" {
  value = aws_lb.jenkins_alb.dns_name
}

output "jenkins_public_ip" {
  value = aws_instance.jenkins_master.public_ip
}

