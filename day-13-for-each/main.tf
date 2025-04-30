provider "aws" {
    region = "ap-south-1"
  
}

variable "ami" {
  type    = string
  default = "ami-0f1dcc636b69a6438"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "env" {
  type    = list(string)
  default = ["server-1", "server-3"]
}

resource "aws_instance" "gayatri" {
  ami           = var.ami
  instance_type = var.instance_type
  for_each      = toset(var.env)
#   count = length(var.env)  

  tags = {
    Name = each.value # for a set, each.value and each.key is the same
  }
}