resource "aws_instance" "gayatri" {
    ami = "ami-0f1dcc636b69a6438"
    instance_type = "t2.micro"
    tags = {
      Name = "my-server"
    }
  
}