#
# Set provider
#
provider "aws" {
  region = "us-east-1"
}
#
# set an instance resource
#
resource "aws_instance" "example" {
  ami		= "ami-40d28157"
  instance_type = "t2.micro"

  tags {
    Name = "terraform-example"
  }

  user_data = <<-EOF
		#!/bin/bash
		echo "Hello World" > index.html
		nohup busybox httpd -f -p 8080 &
		EOF

  vpc_security_group_ids = ["${aws_security_group.instance.id}"]
}
#
# Add a security group to allow inbound 8080 connections
#
resource "aws_security_group" "instance" {
  name = "terraform-example-instance"

  ingress {
    from_port	= 8080
    to_port	= 8080
    protocol	= "tcp"
    cidr_blocks	= ["0.0.0.0/0"]
  }
}

