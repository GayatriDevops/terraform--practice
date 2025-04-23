resource "aws_db_instance" "default" {
  allocated_storage       = 10
  identifier =             "books-rds"
  db_name                 = "gayatridatabase"
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = "db.t3.micro"
  username                = "admin"
  password                = "gayatri1234"
  db_subnet_group_name    = aws_db_subnet_group.sub-grp.id
  parameter_group_name    = "default.mysql8.0"
  provider = aws.primary
  publicly_accessible = true

  # Enable backups and retention
  backup_retention_period  = 7   # Retain backups for 7 days
  backup_window            = "02:00-03:00" # Daily backup window (UTC)

  # Enable monitoring (CloudWatch Enhanced Monitoring)
  monitoring_interval      = 60  # Collect metrics every 60 seconds
  monitoring_role_arn      = aws_iam_role.rds_monitoring-2.arn

  # Enable performance insights
#   performance_insights_enabled          = true
#   performance_insights_retention_period = 7  # Retain insights for 7 days

  # Maintenance window
  maintenance_window = "sun:04:00-sun:05:00"  # Maintenance every Sunday (UTC)

  # Enable deletion protection (to prevent accidental deletion)
  deletion_protection = false
  final_snapshot_identifier = "books-rds-final-snap"

  # Skip final snapshot
  skip_final_snapshot = false
}

# IAM Role for RDS Enhanced Monitoring
resource "aws_iam_role" "rds_monitoring-2" {
  name = "rds-monitoring-role-2"
  provider = aws.primary
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "monitoring.rds.amazonaws.com"
      }
    }]
  })
}

# IAM Policy Attachment for RDS Monitoring
resource "aws_iam_role_policy_attachment" "rds_monitoring_attach" {
    provider = aws.primary
  role       = aws_iam_role.rds_monitoring-2.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}


resource "aws_db_subnet_group" "sub-grp" {
  name       = "mycutsubnet"
  subnet_ids = ["subnet-0d879441838957ac1", "subnet-016f2352d37cba14b"]
  provider = aws.primary

  tags = {
    Name = "My DB subnet group"
  }
}

resource "aws_db_instance" "read_replica" {
  provider               = aws.secondary
  identifier             = "read-replica-instance"
  replicate_source_db    = aws_db_instance.default.arn
  instance_class         = "db.t3.micro"
  skip_final_snapshot    = true
  publicly_accessible    = false
  db_subnet_group_name   = aws_db_subnet_group.replica.name
#   vpc_security_group_ids = [aws_security_group.db_sg.id]
  depends_on             = [aws_db_instance.default]
}

# DB Subnet Group for replica
resource "aws_db_subnet_group" "replica" {
  provider = aws.secondary
  name     = "replica-subnet-group"
  subnet_ids = [
    "subnet-0568b0d6ff21bb569", # replace with subnets in us-east-1
    "subnet-0fe5139e9341825ce"
  ]
}

# # Common security group (could be defined for both regions)
# resource "aws_security_group" "db_sg" {
#   name        = "rds-sg"
#   description = "Allow DB access"
#   vpc_id      = "vpc-xxxxx" # Adjust for each region if needed

#   ingress {
#     from_port   = 3306
#     to_port     = 3306
#     protocol    = "tcp"
#     cidr_blocks = ["10.0.0.0/16"] # Customize this!
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }



