

# This backend configuration instructs Terraform to store its state in an S3 bucket.
 terraform {
backend "s3" {
    bucket         = "gayatridevops"  # Name of the S3 bucket where the state will be stored.
    region         =  "ap-south-1"
    key            = "day-1/terraform.tfstate" # Path within the bucket where the state will be read/written.
    # dynamodb_table = "terraform-state-lock-dynamo" # DynamoDB table used for state locking, note: first run Day4-s3bucket-DynamoDB-create-for-backend-statefile-remote-locking
    encrypt        = true  # Ensures the state is encrypted at rest in S3.
    use_lockfile = true
}
}