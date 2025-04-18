output "public-ip" {
    value = aws_instance.dev.public_ip
    
  
}

output "private-ip" {
    value = aws_instance.dev.private_ip
    sensitive = true
  
}

output "dev" {
    value = aws_s3_bucket.dev.bucket
  
}