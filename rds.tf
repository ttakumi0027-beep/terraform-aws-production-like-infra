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
resource "aws_db_option_group" "mysql_optiongroup" {
  name                 = "${var.project}-${var.environment}-mysql-optiongroup"
  engine_name          = "mysql"
  major_engine_version = "8.0"
}

# ------------------------
# RDS subnet Group
# ------------------------
resource "aws_db_subnet_group" "mysql_subnetgroup" {
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