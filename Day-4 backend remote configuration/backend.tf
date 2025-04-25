
terraform {
  backend "s3" {
    bucket = "gayatridevops" 
    key    = "terraform.tfstate"
    region = "ap-south-1"
    use_lockfile = true
  }
}



