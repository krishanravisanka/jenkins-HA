packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = ">= 1.2.0"
    }
  }
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

source "amazon-ebs" "ubuntu" {
  region                  = var.aws_region
  instance_type           = "t3.medium"
  ssh_username            = "ubuntu"
  ami_name                = "jenkins-master-{{timestamp}}"
  associate_public_ip_address = true

  source_ami_filter {
    filters = {
      virtualization-type = "hvm"
      name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
    }
    owners      = ["099720109477"] # Canonical (Ubuntu)
    most_recent = true
  }
}

build {
  name    = "jenkins-master"
  sources = ["source.amazon-ebs.ubuntu"]

  provisioner "shell" {
    script = "../scripts/install-jenkins.sh"
  }
}
