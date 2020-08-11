provider "aws" {
  region = "us-east-2"
}

module "my_vpc" {
  source  = "terraform-aws-modules/vpc/aws//examples/simple-vpc"
  version = "2.44.0"
}

module "my_web_vpc" {
  source  = "terraform-aws-modules/security-group/aws//modules/web"
  version = "~> 3.0"
  name    = "my_dashboard_web_vpc"
  vpc_id  = module.my_vpc.vpc_id
}

/*
resource "aws_security_group" "sec_grp" {
  name = "dashboard_sec_grp"

  egress {
    from_port   = -1
    to_port     = -1
    protocol    = "https"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

}
*/

resource "aws_instance" "dashboard" {
  # Amazon Linux AMI amzn-ami-2018.03.20200805 x86_64 ECS HVM GP2 
  ami                    = "ami-0e18fc717d49b88a1"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [module.my_web_vpc.this_security_group_id]

  tags = {
    Name = "dashboard_cd"
  }

  user_data = <<-EOF
    #!/bin/bash
    docker pull peterskipper/dashboard_cd && docker run -p 8501:8501 dashboard_cd
    EOF

  # security_groups = [aws_security_group.sec_grp.id]

}

output "sec_grp_id" {
  value       = module.my_web_vpc.this_security_group_id
  description = "working, maybe?"
}
