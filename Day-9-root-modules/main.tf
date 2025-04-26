# module "ec2" {
#     source = "./module/ec2-instance"
#     ami = var.ami
#     instance_type = var.instance_type
  
# }


module "rds" {
  source = "./module/rds"

  identifier                    = "books-rds"
  db_name                       = "gayatridatabase"
  engine                        = "mysql"
  engine_version                = "8.0"
  instance_class                = "db.t3.micro"
  username                      = "admin"
  password                      = "gayatri1234"
  subnet_ids                    = ["subnet-0d879441838957ac1", "subnet-016f2352d37cba14b"]
  parameter_group_name          = "default.mysql8.0"
  backup_retention_period       = 7
  backup_window                 = "02:00-03:00"
  maintenance_window            = "sun:04:00-sun:05:00"
  deletion_protection           = false
  final_snapshot_identifier     = "books-rds-final-snap"
  skip_final_snapshot           = false
  monitoring_interval           = 60
  monitoring_role_name          = "rds-monitoring-role-20"
  create_monitoring_role        = true
  publicly_accessible           = true
  tags = {
    Name        = "My DB"
    Environment = "dev"
  }
  providers = {
    aws = aws.primary
  }
}
















































