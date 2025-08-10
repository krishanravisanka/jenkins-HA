# Create the EFS File System
resource "aws_efs_file_system" "jenkins_efs" {
  creation_token = "jenkins-efs"
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"

  tags = {
    Name = "jenkins-efs"
  }
}
# aws_efs_file_system.jenkins_efs.dns_name
# Mount Target for AZ-a
resource "aws_efs_mount_target" "az_a" {
  file_system_id  = aws_efs_file_system.jenkins_efs.id
  subnet_id       = aws_subnet.public_subnet_1.id
  security_groups = [aws_security_group.efs_sg.id]
}

# Mount Target for AZ-b
resource "aws_efs_mount_target" "az_b" {
  file_system_id  = aws_efs_file_system.jenkins_efs.id
  subnet_id       = aws_subnet.public_subnet_2.id
  security_groups = [aws_security_group.efs_sg.id]
}
