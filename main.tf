terraform {
backend "s3" {
    bucket         = "testingbucket-testing"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraformtesting-dynamoDB"
  }
}

variable "awsprops" {
    type = map(string)
    default = {
       region = "us-east-1"
       vpc = "vpc-06ce3ede03067277f"
       ami = "ami-03ededff12e34e59e"
       itype = "t2.micro"
       subnet = "subnet-0a3e82b9d34923ea2"
       publicip = true
       keyname = "varalu-testing"
       secgroupname = "IAC-Sec-Group"
  }
}


provider "aws" {
    access_key = "${var.access_key}"
    secret_key = "${var.secret_key}"
    region = lookup(var.awsprops, "region")
}

resource "aws_security_group" "project-iac-sg" {
  name = lookup(var.awsprops, "secgroupname")
  description = lookup(var.awsprops, "secgroupname")
  vpc_id = lookup(var.awsprops, "vpc")

  // To Allow SSH Transport
  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  // To Allow Port 80 Transport
  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_instance" "project-iac" {
  ami = lookup(var.awsprops, "ami")
  instance_type = lookup(var.awsprops, "itype")
  subnet_id = lookup(var.awsprops, "subnet") #FFXsubnet2
  associate_public_ip_address = lookup(var.awsprops, "publicip")
  key_name = lookup(var.awsprops, "keyname")

  vpc_security_group_ids = [
    aws_security_group.project-iac-sg.id
  ]
  root_block_device {
    delete_on_termination = true
    volume_size = 8
    volume_type = "gp2"
  }

  tags = {
    name = "${var.name}",
    env = "${var.env}"
  }

  depends_on = [ aws_security_group.project-iac-sg ]
}


