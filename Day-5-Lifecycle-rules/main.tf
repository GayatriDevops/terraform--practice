resource "aws_instance" "gayatri" {
    ami = "ami-0f1dcc636b69a6438"
    instance_type = "t2.micro"
    availability_zone = "ap-south-1b"

    tags = {
      Name = "test"
    }


  # lifecycle {
  #   prevent_destroy = true
  # }
#   lifecycle {
#    create_before_destroy = true
#  }

# lifecycle {
#     ignore_changes = [ tags,]
#   }
}
