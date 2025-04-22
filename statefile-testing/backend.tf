terraform {
  backend "s3" {
    bucket = "gayatridevops" 
    key    = "test/terraform.tfstate"
    region = "ap-south-1"
  }
}