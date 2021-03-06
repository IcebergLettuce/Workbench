
# TODO: Add provisioning of the elastic IP and the DNS records.

terraform {
 required_providers {
   aws = {
     source  = "hashicorp/aws"
     version = "~> 3.0"
   }
 }

 backend "s3" {
   bucket         = "workbench-infrastructure-state"
   key            = "state/terraform.tfstate"
   region         = "eu-central-1"
   encrypt        = true
   dynamodb_table = "workbench-infrastructure-state"
 }
}


provider "aws" {
  profile = "default"
  region  = "eu-central-1"
}

resource "aws_security_group" "workbench" {
  name        = "workbench-security-group"
  description = "Allow HTTP, HTTPS, AMQP and SSH traffic"

  ingress {
    description = "AMQP"
    from_port   = 5672
    to_port     = 5672
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "workbench"
  }
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = "${aws_instance.workbench.id}"
  allocation_id = "eipalloc-78a96a79"
}

resource "aws_instance" "workbench" {
  key_name      = "workbench"
  ami           = "ami-05f7491af5eef733a"
  instance_type = "t2.medium"

  tags = {
    Name = "workbench"
  }

  vpc_security_group_ids = [
    aws_security_group.workbench.id
  ]

  ebs_block_device {
    device_name = "/dev/sda1"
    volume_type = "gp2"
    volume_size = 30
  }
}
