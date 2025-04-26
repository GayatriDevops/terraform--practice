resource "aws_instance" "dev" {
    ami = var.ami
    instance_type = var.instance_type
}