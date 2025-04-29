provider "aws" {
  region = "ap-south-1"
}

locals {
  # db_name     = "sample_db"
  db_username = "admin"
  db_password = "gayatri123"
}

# Create Secrets Manager secret
resource "aws_secretsmanager_secret" "rds_secret" {
  name = "rds-credentials"
}

resource "aws_secretsmanager_secret_version" "rds_secret_version" {
  secret_id     = aws_secretsmanager_secret.rds_secret.id
  secret_string = jsonencode({
    username = local.db_username
    password = local.db_password
    # dbname   = local.db_name
  })
}

# DB Subnet Group
resource "aws_db_subnet_group" "private_subnet_group" {
  name       = "private-subnet-group"
  subnet_ids = ["subnet-02a671902024bb49c", "subnet-0521d45c650c0d614"]
}

# Security Group to allow MySQL access from EC2 instance
resource "aws_security_group" "rds_sg" {
  name        = "rds-sg"
  description = "Allow MySQL access"
  vpc_id      = "vpc-0b43f92af531fb44a" # Replace with your VPC ID

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Restrict this for production
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Restrict this for production
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create RDS instance
resource "aws_db_instance" "mysql_rds" {
  identifier           = "test"
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0.41" # Replace with valid MySQL version
  instance_class       = "db.t3.micro"
  db_subnet_group_name = aws_db_subnet_group.private_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  username             = local.db_username
  password             = local.db_password
  skip_final_snapshot  = true
  publicly_accessible  = false
}

# EC2 Instance for running SQL script
resource "aws_instance" "sql_runner" {
  ami                         = "ami-0f1dcc636b69a6438"
  instance_type               = "t2.micro"
  key_name                    = "mum-key"
  associate_public_ip_address = true
  subnet_id                   = "subnet-0d5019a3a56a6bd04" # Ensure it's a public subnet
  vpc_security_group_ids      = [aws_security_group.rds_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name  # Attach the IAM profile here

  tags = {
    Name = "Database-server"
  }
}

# IAM role for EC2
resource "aws_iam_role" "ec2_secrets_role" {
  name = "ec2-secrets-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [ {
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

# IAM policy for EC2 to access Secrets Manager
resource "aws_iam_policy" "secrets_policy" {
  name = "allow-secrets-access"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "secretsmanager:GetSecretValue"
      ],
      Resource = aws_secretsmanager_secret.rds_secret.arn
    }]
  })
}

# IAM instance profile for EC2 instance
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-secrets-instance-profile"
  role = aws_iam_role.ec2_secrets_role.name
}

# Attach policy to EC2 role
resource "aws_iam_role_policy_attachment" "attach_secrets_policy" {
  role       = aws_iam_role.ec2_secrets_role.name
  policy_arn = aws_iam_policy.secrets_policy.arn
}

# Run init.sql remotely on EC2 instance
resource "null_resource" "remote_sql_exec" {
  depends_on = [
    aws_db_instance.mysql_rds,
    aws_instance.sql_runner
  ]

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("C:/Users/prade/Downloads/mum-key.pem") #private key.pem path
    host        = aws_instance.sql_runner.public_ip
  }

    provisioner "file" {
    source      = "init.sql"
    destination = "/tmp/init.sql"
  }

    provisioner "remote-exec" {
    inline = [
       "sudo yum install -y mariadb105",
      "aws secretsmanager get-secret-value --secret-id rds-credentials --query SecretString --output text > /tmp/creds.json",
      "DB_USER=$(jq -r .username /tmp/creds.json)",
      "DB_PASS=$(jq -r .password /tmp/creds.json)",
      # "DB_NAME=$(jq -r .dbname /tmp/creds.json)",
      "mysql -h ${aws_db_instance.mysql_rds.address} -u $DB_USER -p$DB_PASS < /tmp/init.sql"
    ]
  }




  triggers = {
    always_run = timestamp()  # Forces the null_resource to always re-run on each apply
  }
}
