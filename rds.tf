# ------------------------
# RDS parameter group
# ------------------------
resource "aws_db_parameter_group" "mysql_parameter_group" {
  name   = "${var.project}-${var.environment}-mysql-parametergroup"
  family = "mysql8.0"

  parameter {
    name  = "character_set_database"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }

  parameter {
    name  = "time_zone"
    value = "Asia/Tokyo"
  }
}


# ------------------------
# RDS option Group
# ------------------------
resource "aws_db_option_group" "mysql_option_group" {
  name                 = "${var.project}-${var.environment}-mysql-optiongroup"
  engine_name          = "mysql"
  major_engine_version = "8.0"
}

# ------------------------
# RDS subnet Group
# ------------------------
resource "aws_db_subnet_group" "mysql_subnet_group" {
  name = "${var.project}-${var.environment}-mysql-subnetgroup"
  subnet_ids = [
    aws_subnet.db_private_subnet_1a.id,
    aws_subnet.db_private_subnet_1c.id
  ]

  tags = {
    Name    = "${var.project}-${var.environment}-mysql-subnetgroup"
    Project = var.project
    Env     = var.environment
  }
}

# ------------------------
# RDS instance
# ------------------------
resource "aws_db_instance" "mysql_server" {
  engine         = "mysql"
  engine_version = "8.0"
  identifier     = "${var.project}-${var.environment}-mysql-server"

  username       = var.db_username
  password       = var.db_password
  port           = 3306
  instance_class = "db.t3.micro"

  allocated_storage     = 20
  max_allocated_storage = 100
  storage_encrypted     = true
  storage_type          = "gp3"

  multi_az                   = true
  publicly_accessible        = false
  deletion_protection        = false
  skip_final_snapshot        = false
  apply_immediately          = true
  auto_minor_version_upgrade = true

  backup_retention_period = 7
  backup_window           = "04:00-05:00"
  maintenance_window      = "Mon:05:00-Mon:08:00"

  db_subnet_group_name   = aws_db_subnet_group.mysql_subnet_group.name
  parameter_group_name   = aws_db_parameter_group.mysql_parameter_group.name
  option_group_name      = aws_db_option_group.mysql_option_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  enabled_cloudwatch_logs_exports = ["error", "general", "slowquery"]

  tags = {
    Name    = "${var.project}-${var.environment}-mysql"
    Project = var.project
    Env     = var.environment
  }

  depends_on = [
    aws_db_subnet_group.mysql_subnet_group,
    aws_db_parameter_group.mysql_parameter_group,
    aws_db_option_group.mysql_option_group,
    aws_security_group.rds_sg
  ]
}