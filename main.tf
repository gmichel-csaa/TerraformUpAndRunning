#
### Set provider ###
#
provider "aws" {
  region = "us-east-1"
}
#
#
### Variables ###
#
#
# set server port #
#
variable "server_port" {
  description = "The port the web server will use in this example for HTTP requests"
  default = 8080
}
#
#
### Resources ###
#
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
		nohup busybox httpd -f -p "${var.server_port}" &
		EOF

  vpc_security_group_ids = ["${aws_security_group.WebServerSecurityGroup.id}"]
}
#
# Add a security group to allow inbound 8080 connections
#
resource "aws_security_group" "WebServerSecurityGroup" {
  name = "Web Server Security Group"

  ingress {
    from_port	= "${var.server_port}"
    to_port	= "${var.server_port}"
    protocol	= "tcp"
    cidr_blocks	= ["0.0.0.0/0"]
  }
}
#
#
### Outputs ###
#
#
# Instance public IP address #
#
output "Public IP" {
  value = "${aws_instance.example.public_ip}"
}
#
# end #
 
