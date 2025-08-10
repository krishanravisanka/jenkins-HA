variable "aws_region" {
  description = "The Region for the aws jenkins setup"
  type        = string
  default     = "us-east-1"
}
# variable "jenkins_ami_id" {
#   description = "AMI ID of Jenkins master (from Packer)"
# }

variable "key_pair_name" {
  description = "SSH key pair name for EC2 access"
  default = "jenkins-key-pair"
}
