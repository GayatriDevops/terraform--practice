resource "aws_db_subnet_group" "subnet_group" {
  name       = "${var.identifier}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(var.tags, {
    Name = "${var.identifier}-subnet-group"
  })
}

resource "aws_iam_role" "monitoring" {
  count = var.create_monitoring_role ? 1 : 0

  name = var.monitoring_role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Principal = {
        Service = "monitoring.rds.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "monitoring_attach" {
  count      = var.create_monitoring_role ? 1 : 0
  role       = aws_iam_role.monitoring[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

resource "aws_db_instance" "this" {
  allocated_storage       = 10
  identifier              = var.identifier
  db_name                 = var.db_name
  engine                  = var.engine
  engine_version          = var.engine_version
  instance_class          = var.instance_class
  username                = var.username
  password                = var.password
  port                    = 3306
  db_subnet_group_name    = aws_db_subnet_group.subnet_group.name
  parameter_group_name    = var.parameter_group_name
  publicly_accessible     = var.publicly_accessible
  backup_retention_period = var.backup_retention_period
  backup_window           = var.backup_window
  maintenance_window      = var.maintenance_window
  deletion_protection     = var.deletion_protection
  final_snapshot_identifier = var.final_snapshot_identifier
  skip_final_snapshot     = var.skip_final_snapshot
  monitoring_interval     = var.monitoring_interval
  monitoring_role_arn     = var.create_monitoring_role ? aws_iam_role.monitoring[0].arn : null

  tags = var.tags
}
