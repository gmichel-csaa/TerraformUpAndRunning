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
resource "aws_launch_configuration" "LaunchConfigurationExample" {
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
  launch_configuration	= "${aws_launch_configuration.LaunchConfigurationExample.id}"
  availability_zones	= ["${data.aws_availability_zones.all.names}"]

  load_balancers	= ["${aws_elb.ElasticLoadBalancerExample}"]
  health_check_type	= "ELB"

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
# Elastic Load Balancer #
#
resource "aws_elb" "ElasticLoadBalancerExample" {
  name			= "Terraform Auto Scaler Group"
  availability_zones	= ["${data.aws_availability_zones.all.names}"]
  security_groups	= ["${aws_security_group.elb.id}"] ## this associates the ELB with its security group
 
  listener {
    lb_port		= 80
    lb_protocol		= "http"
    instance_port	= "${var.server_port}"
    instance_protocol	= "http"
  }

  health_check {
    healthy_threshold	= 2
    unhealthy_threshold = 2
    timeout		= 3
    inverval		= 30
    target		= "HTTP:${var.server_port}/"
  }
}
#
## Security group for the elastic load balancer ##
#
resource "aws_security_group" "elb" {
  name = "Security Group for ELB"

  ingress {
    from_port		= 80
    to_port		= 80
    protocol		= "tcp"
    cidr_blocks		= ["0.0.0.0/0"]
  }

  egress {
    from_port		= 0
    to_port		= 0
    protocol		= 1
    cidr_blocks 	= ["0.0.0.0/0"]
  }
}
#
#
### Outputs ###
#
#
# Instance public IP address / ELB DNS name #
#
output "Public IP" {
  value = "${aws_elb.ElassticLoadBalancerExample.dns_name}"
}
#
# end #
