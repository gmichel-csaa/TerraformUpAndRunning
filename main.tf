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
### Data Sources ###
#
# AZs
#
data "aws_availability_zones" "all" {}
#
#
### Resources ###
#
#
# set a launch configuration resource for instances
#
resource "aws_launch_configuration" "LCExample" {
  image_id	= "ami-40d28157"
  instance_type = "t2.micro"

###  tag {
###    Name = "Launch Configuration Example"
###  }

  user_data = <<-EOF
		#!/bin/bash
		echo "Hello World" > index.html
		nohup busybox httpd -f -p "${var.server_port}" &
		EOF

  security_groups = ["${aws_security_group.WebServerSecurityGroup.id}"]

  lifecycle {
    create_before_destroy = true
  }
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
  lifecycle {
    create_before_destroy = true
  }
}
#
# Auto Scaling Group #
#
resource "aws_autoscaling_group" "AutoScalingGroupExample" {
  launch_configuration = "${aws_launch_configuration.LaunchConfigurationExample.id}"
  availability_zones   = ["${data.aws_availability_zones.all.names}"]

  min_size = 2
  max_size = 10
  desired_capacity = 4

  tags {
    key			= "Name"
    value		= "Terraform Auto Scaling Group example"
    propagate_at_launch	= true
  }
}
#
#
### Outputs ###
#
#
# Instance public IP address #
#
###output "Public IP" {
###  value = "${aws_instances.LaunchConfigurationExample.public_ip}"
###}
#
# end #

