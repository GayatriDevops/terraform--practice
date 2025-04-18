resource "aws_instance" "dev" {
    ami = "ami-0f1dcc636b69a6438"
    instance_type = "t2.micro"
  
}
resource "aws_vpc" "test" {
    cidr_block = "192.168.1.0/24"
    depends_on = [ aws_instance.dev ]
  
}
