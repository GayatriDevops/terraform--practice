provider "aws" {
    region = "ap-south-1"
  
}



# resource "aws_instance" "name" {
#     ami = "ami-0f1dcc636b69a6438"
#     instance_type = "t2.micro"
#     key_name = "mum-key"
#     availability_zone = "ap-south-1a"
#     count = 2
#     # tags = {
#     #   Name = "server-1"   #two resource will create on same name 
#     # }

#     tags = {
#       Name = "dev-${count.index}"
#     }
# }
   
  
# 
############################### Example-2 Different names #############
variable "env" {
  type    = list(string)
  default = [ "dev", "prod"]
}

resource "aws_instance" "name" {
    ami = "ami-0f1dcc636b69a6438"
    instance_type = "t2.micro"
    count=length(var.env)

    tags = {
      Name = var.env[count.index]
    }
}


# # main.tf
# resource "aws_instance" "sandbox" {
#   ami           = var.ami
#   instance_type = var.instance_type
#   count         = length(var.sandboxes)

#   tags = {
#     Name = var.sandboxes[count.index]
#   }
# }

# #example-3 creating IAM users 
# # variable "user_names" {
# #   description = "IAM usernames"
# #   type        = list(string)
# #   default     = ["user1", "user2", "user3"]
# # }
# # resource "aws_iam_user" "example" {
# #   count = length(var.user_names)
# #   name  = var.user_names[count.index]
# # }