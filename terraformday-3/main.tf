resource "aws_instance" "dev" {
    ami = var.ami
    instance_type = var.instance_type
  
}

resource "aws_s3_bucket" "dev" {
    bucket = var.aws_s3_bucket

  
}
