terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.8.0"
    }
  }
  required_version = ">= 1.1.5"
}


provider "aws" {
  region = "us-east-1" # Specified AWS region
}


resource "aws_instance" "Dockerpractice" {
  ami           = "ami-053b0d53c279acc90"
  instance_type = "t2.micro"
  key_name      = "promokey"  # Specify your AWS key pair without the ".pem" extension
  vpc_security_group_ids = [aws_security_group.sg_8000.id]
  user_data              = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install docker.io -y
              apt-get install -y git
              systemctl start docker
              usermod -a -G docker ubuntu  # Changed to 'ubuntu' as the username
              EOF
  
  tags = {
    Name = "terraform-learn-state-ec2"
  }
}

resource "aws_security_group" "sg_8000" {
  name = "terraform-learn-state-sg"
  ingress {
    from_port   = "8000" # Allow incoming traffic on port 8000 (your application)
    to_port     = "8000"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 22 # Allow incoming SSH traffic
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress rule to allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Use "-1" to specify all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "instance_id" {
  value = aws_instance.Dockerpractice.id
}

output "public_ip" {
  value       = aws_instance.Dockerpractice.public_ip
  description = "The public IP of the web server"
}

output "security_group" {
  value = aws_security_group.sg_8000
}