resource "aws_instance" "name" {
    ami = "ami-0f1dcc636b69a6438"
    instance_type = "t2.micro"
    key_name = "mum-key"
    availability_zone = "ap-south-1a"
    user_data = file("test.sh")
}