provider "aws" {
  region = "ap-south-1"  # Adjust to your desired region
}
#creating key-pair
resource "aws_key_pair" "example" {
  key_name   = "gayatri"  # Replace with your desired key name
  public_key = file("C:/Users/prade/.ssh/id_ed25519.pub")
}




# Create an S3 bucket for storing logs
resource "aws_s3_bucket" "log_bucket" {
  bucket = "gayatridevops"  # Ensure this name is globally unique
  acl    = "private"
}

# Create an IAM role for the EC2 instance
resource "aws_iam_role" "ec2_role" {
  name = "EC2CloudWatchRole"

  assume_role_policy = jsonencode ({
   
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:PutLogEvents",
        "logs:CreateLogStream",
        "logs:CreateLogGroup"
      ],
      "Resource": "*"
    }
  ]
})
}



# Attach policies to the IAM role
resource "aws_iam_role_policy_attachment" "cloudwatch_agent_policy" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = aws_iam_role.ec2_role.name
}

resource "aws_iam_role_policy_attachment" "s3_access_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = aws_iam_role.ec2_role.name
}

# Create an IAM instance profile for the EC2 instance
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "EC2CloudWatchProfile"
  role = aws_iam_role.ec2_role.name
}

# Create a CloudWatch Log Group
resource "aws_cloudwatch_log_group" "log_group" {
  name = "MyAppLogGroup"
}

# Create a CloudWatch Log Stream
resource "aws_cloudwatch_log_stream" "log_stream" {
  name           = "MyAppLogStream"
  log_group_name = aws_cloudwatch_log_group.log_group.name
}

# EC2 instance with CloudWatch Agent installation
resource "aws_instance" "my_instance" {
  ami           = "ami-0f1dcc636b69a6438"  # Amazon Linux 2 AMI (adjust for your region)
  instance_type = "t2.micro"
  key_name      = aws_key_pair.example.key_name

  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y amazon-cloudwatch-agent
              /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
                -a fetch-config -m ec2 -c file:/tmp/cloudwatch-agent-config.json -s
              EOF

  tags = {
    Name = "MyAppInstance"
  }
}

# Create CloudWatch Agent configuration file
resource "null_resource" "cloudwatch_agent_config" {
  triggers = {
    instance_state = aws_instance.my_instance.instance_state
    config_hash = sha1(file("cloudwatch-agent-config.json"))
  }

  provisioner "file" {
    source      = "cloudwatch-agent-config.json"
    destination = "/tmp/cloudwatch-agent-config.json"
    
    connection {
      host        = aws_instance.my_instance.public_ip
      type        = "ssh"
      user        = "ec2-user"  # Default user for Amazon Linux 2
      private_key = file("C:/Users/prade/.ssh/id_ed25519")  # Path to your private key
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a stop",
      "sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a start"
    ]
    
    connection {
      host        = aws_instance.my_instance.public_ip
      type        = "ssh"
      user        = "ec2-user"  # Default user for Amazon Linux 2
      private_key = file("C:/Users/prade/.ssh/id_ed25519")  # Path to your private key
    }
  }
}

# Lambda function to export logs from CloudWatch to S3
resource "aws_lambda_function" "log_exporter" {
  function_name = "LogExporterFunction"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "index.lambda_handler"
  runtime       = "python3.8"  # You can choose the appropriate Python version

  # Specify the path to the zip file
  filename      = "lambda_function.zip"  # Ensure the file is in the correct path

  source_code_hash = base64sha256(filebase64("lambda_function.zip"))

  environment {
    variables = {
      S3_BUCKET = aws_s3_bucket.log_bucket.bucket
    }
  }
}



# IAM role for Lambda function
resource "aws_iam_role" "lambda_exec_role" {
  name = "LambdaExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Attach policies to Lambda execution role
resource "aws_iam_role_policy_attachment" "lambda_logs_policy" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsReadOnlyAccess"
  role       = aws_iam_role.lambda_exec_role.name
}

resource "aws_iam_role_policy_attachment" "lambda_s3_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = aws_iam_role.lambda_exec_role.name
}

# CloudWatch Log Subscription Filter to trigger Lambda function
resource "aws_cloudwatch_log_subscription_filter" "log_subscription" {
  name            = "MyAppLogSubscription"
  log_group_name  = aws_cloudwatch_log_group.log_group.name
  filter_pattern  = ""
  destination_arn = aws_lambda_function.log_exporter.arn
}

# Permissions for CloudWatch Logs to invoke Lambda
resource "aws_lambda_permission" "allow_cloudwatch_logs" {
  statement_id  = "AllowCloudWatchLogsInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.log_exporter.function_name
  principal     = "logs.amazonaws.com"
}
