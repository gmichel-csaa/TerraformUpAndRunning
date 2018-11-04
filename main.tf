#
# Set provider
#
provider "aws" {
  region = "us-east-1"
}
#
# set resource
#
resource "aws_instance" "example" {
  ami		= "ami-40d28157"
  instance_type = "t2.micro"
}


