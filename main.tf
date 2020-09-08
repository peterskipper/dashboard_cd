provider "aws" {
  region = "us-east-2"
}

variable "docker_image_tag" {
  type        = string
  description = "Tag of the docker image. Comes from the git sha for this PR"
  validation {
    condition     = length(var.docker_image_tag) == 8
    error_message = "Var docker_image_tag must be 8 chars long, not ${var.docker_image_tag}"
  }
}

resource "aws_default_vpc" "default_vpc" {
  tags = {
    Name = "Default VPC"
  }
}

resource "aws_security_group" "sec_grp" {
  name   = "dashboard_sec_grp"
  vpc_id = aws_default_vpc.default_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}


resource "aws_instance" "dashboard" {
  # Amazon Linux AMI amzn-ami-2018.03.20200805 x86_64 ECS HVM GP2 
  ami           = "ami-0e18fc717d49b88a1"
  instance_type = "t2.micro"
  key_name      = "aws-pskip-2020-08-10"

  vpc_security_group_ids = [aws_security_group.sec_grp.id]
  tags = {
    Name = "dashboard_cd"
  }

  user_data = <<-EOF
    #!/bin/bash
    docker pull peterskipper/dashboard_cd:${var.docker_image_tag}
    docker run -p 80:8501 peterskipper/dashboard_cd:${var.docker_image_tag}
    EOF
}

output "dashboard_ip" {
  value       = aws_instance.dashboard.public_ip
  description = "The public IP of the Dashboard"
}

output "dashboard_public_dns" {
  value       = aws_instance.dashboard.public_dns
  description = "Public DNS for your default VPC"
}
