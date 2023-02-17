provider "aws" {
  region     = "ap-southeast-1"
  access_key = var.AWS_ACCESS_KEY_ID
  secret_key = var.AWS_SECRET_ACCESS_KEY
}

resource "aws_security_group" "instance_security_group" {
  name = var.security_group
  description = "Allow 4 port (443,80,22,3306) to be accessed"

  #http
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  #ssh
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #https
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  #MYSQL DB port
  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "Learn-Terraform" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_pair
  vpc_security_group_ids = ["${aws_security_group.instance_security_group.id}"]
  tags = {
    Name = var.tag_name
  }

  root_block_device {
    volume_size = 8
  }
}

