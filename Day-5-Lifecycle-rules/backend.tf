terraform {
  backend "s3" {
    bucket = "gayatridevops" 
    key    = "day-5/terraform.tfstate"
    region = "ap-south-1"
  }
}